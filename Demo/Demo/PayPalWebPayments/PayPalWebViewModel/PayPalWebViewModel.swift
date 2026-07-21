import Foundation
import CorePayments
import PayPalWebPayments
import FraudProtection

@MainActor
class PayPalWebViewModel: ObservableObject {

    private enum DemoFixtures {
        static let amount = Amount(currencyCode: "USD", value: "10.00")
        static let vaultAttributes = Vault(storeInVault: "ON_SUCCESS", usageType: "MERCHANT", customerType: "CONSUMER")
    }

    @Published var state = PayPalPaymentState()
    @Published var intent: Intent = .authorize
    @Published var order: Order?
    @Published var checkoutResult: PayPalWebCheckoutResult?
    @Published var appSwitch = false
    @Published private(set) var isSessionPrepared = false
    @Published private(set) var isPreparingSession = false

    let appSwitchURL = Environment.sandbox.baseURL

    var payPalWebCheckoutClient: PayPalWebCheckoutClient?

    private var shouldVaultCheckout = false

    var orderID: String? {
        order?.id
    }

    let configManager = CoreConfigManager(domain: "PayPalWeb Payments")
    private var payPalDataCollector: PayPalDataCollector?

    /// Starts the SSID session. Order creation happens when the PayPal button is tapped via
    /// `start(createOrder:)` so the SDK can emit `api-request-latency`.
    func prepareSession(
        shouldVault: Bool,
        userAction: PayPalUserAction,
        userIdentity: PayPalUserIdentity?
    ) async throws {
        isPreparingSession = true
        defer { isPreparingSession = false }

        guard let client = try await getPayPalClient() else {
            throw CheckoutError.clientInitializationFailed("Error initializing PayPalWebCheckoutClient")
        }
        payPalWebCheckoutClient = client
        shouldVaultCheckout = shouldVault

        client.createPayPalSession(
            userIdentity: userIdentity,
            urlConfig: ShopperSessionURLConfigFactory.urlConfig,
            userAction: userAction
        )

        isSessionPrepared = true
        print("✅ PayPal session prepared — tap a PayPal button to create the order and checkout")
    }

    func paymentButtonTapped(funding: PayPalWebCheckoutFundingSource) {
        Task {
            do {
                print("▶️ PayPal checkout button tapped with funding: \(funding.rawValue)")
                state.approveResultResponse = .loading

                if payPalWebCheckoutClient == nil {
                    payPalWebCheckoutClient = try await getPayPalClient()
                }
                guard let payPalWebCheckoutClient else {
                    state.approveResultResponse = .error(message: "Missing PayPal client")
                    return
                }

                guard isSessionPrepared else {
                    state.approveResultResponse = .error(message: "Tap Prepare Session before checkout.")
                    return
                }

                print("📊 Using start(createOrder:) — emits paypal-web-payments:api-request-latency")
                payPalWebCheckoutClient.start(createOrder: {
                    let order = try await self.fetchOrder(shouldVault: self.shouldVaultCheckout)
                    return order.id
                }, completion: { result in
                    switch result {
                    case .success(let checkoutResult):
                        self.handleCheckoutResult(.success(checkoutResult))
                    case .failure(let error):
                        self.fallbackToLegacyCheckout(funding: funding, error: error)
                    }
                })
            } catch {
                print("❌ PayPal checkout failed to start: \(error.localizedDescription)")
                state.approveResultResponse = .error(message: error.localizedDescription)
            }
        }
    }

    private func fallbackToLegacyCheckout(
        funding: PayPalWebCheckoutFundingSource,
        error: CoreSDKError
    ) {
        guard let payPalWebCheckoutClient, let orderID = state.createOrder?.id else {
            print("❌ PayPal checkout failed: \(error.localizedDescription)")
            handleCheckoutResult(.failure(error))
            return
        }

        print("⚠️ SSID checkout failed after api-request-latency; falling back to legacy checkout: \(error.localizedDescription)")
        let payPalRequest = PayPalWebCheckoutRequest(
            orderID: orderID,
            fundingSource: funding,
            appSwitchIfEligible: appSwitch
        )
        payPalWebCheckoutClient.start(request: payPalRequest) { result in
            self.handleCheckoutResult(result)
        }
    }

    private func handleCheckoutResult(_ result: Result<PayPalWebCheckoutResult, CoreSDKError>) {
        switch result {
        case .success(let paypalResult):
            state.approveResultResponse = .loaded(
                PayPalPaymentState.ApprovalResult(id: paypalResult.orderID, status: "APPROVED")
            )
            checkoutResult = paypalResult
            print("✅ Checkout result: \(String(describing: paypalResult))")
        case .failure(let error):
            if error == PayPalError.checkoutCanceledError {
                print("Canceled")
                state.approveResultResponse = .idle
            } else {
                print("❌ PayPal checkout failed: \(error.localizedDescription)")
                state.approveResultResponse = .error(message: error.localizedDescription)
            }
        }
    }

    /// S1: No payment source (non app-switch, non vault)
    /// S2: PayPal app-switch (no vault) -> experienceContext with appSwitchContext
    /// S3: PayPal vault (no app-switch)  -> attributes.vault + experienceContext
    /// S4: PayPal vault + app-switch     -> attributes.vault + experienceContext.appSwitchContext
    private func fetchOrder(shouldVault: Bool) async throws -> Order {
        do {
            let amountRequest = DemoFixtures.amount

            var paymentSource: OrderPaymentSource?

            if appSwitch || shouldVault {
                let experience = PayPalExperienceContext(
                    returnUrl: appSwitchURL + "/success",
                    cancelUrl: appSwitchURL + "/cancel",
                    appSwitchContext: appSwitch ? AppSwitchContext(appUrl: appSwitchURL) : nil
                )

                let attributes: Attributes? = shouldVault ? Attributes(vault: DemoFixtures.vaultAttributes) : nil

                let paypal = PayPalSource(attributes: attributes, experienceContext: experience)
                paymentSource = .paypal(OrderPayPalPaymentSource(paypal: paypal))
            }

            let params = CreateOrderParams(
                applicationContext: nil,
                intent: intent.rawValue,
                purchaseUnits: [PurchaseUnit(amount: amountRequest)],
                paymentSource: paymentSource
            )

            state.createdOrderResponse = .loading
            let order = try await DemoMerchantAPI.sharedService.createOrder(
                orderParams: params,
                selectedMerchantIntegration: DemoSettings.merchantIntegration
            )
            self.order = order
            state.createdOrderResponse = .loaded(order)
            print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            return order
        } catch {
            state.createdOrderResponse = .error(message: error.localizedDescription)
            throw error
        }
    }

    func getPayPalClient() async throws -> PayPalWebCheckoutClient? {
        do {
            let config = try await configManager.getCoreConfig()
            let payPalClient = PayPalWebCheckoutClient(config: config)
            payPalDataCollector = PayPalDataCollector(config: config)
            return payPalClient
        } catch {
            print("❌ failed to create PayPalWebCheckoutClient with error: \(error.localizedDescription)")
            return nil
        }
    }

    func completeTransaction() async throws {
        do {
            setLoadingState()
            if let orderID = state.createOrder?.id {
                let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
                let order = try await DemoMerchantAPI.sharedService.completeOrder(
                    intent: intent,
                    orderID: orderID,
                    payPalClientMetadataID: payPalClientMetadataID
                )
                setOrderCompletionLoadedState(order: order)
            }
        } catch {
            setErrorState(message: error.localizedDescription)
        }
    }

    private func setLoadingState() {
        switch intent {
        case .authorize:
            state.authorizedOrderResponse = .loading
        case .capture:
            state.capturedOrderResponse = .loading
        }
    }

    private func setOrderCompletionLoadedState(order: Order) {
        switch intent {
        case .authorize:
            state.authorizedOrderResponse = .loaded(order)
        case .capture:
            state.capturedOrderResponse = .loaded(order)
        }
    }

    private func setErrorState(message: String) {
        switch intent {
        case .authorize:
            state.authorizedOrderResponse = .error(message: message)
        case .capture:
            state.capturedOrderResponse = .error(message: message)
        }
    }

    func resetState() {
        state = PayPalPaymentState()
        order = nil
        checkoutResult = nil
        payPalWebCheckoutClient = nil
        isSessionPrepared = false
        isPreparingSession = false
        shouldVaultCheckout = false
    }

    func handleUniversalLinkReturn(_ url: URL) {
        guard let payPalWebCheckoutClient else { return }
        payPalWebCheckoutClient.handleReturnURL(url)
    }
}

private enum CheckoutError: LocalizedError {
    case clientInitializationFailed(String)

    var errorDescription: String? {
        switch self {
        case .clientInitializationFailed(let message):
            return message
        }
    }
}
