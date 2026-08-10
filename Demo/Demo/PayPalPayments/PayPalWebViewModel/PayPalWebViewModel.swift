import Foundation
import CorePayments
import PayPalPayments
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
    @Published var checkoutResult: PayPalCheckoutResult?

    let appSwitchURL = DemoSettings.environment.baseURL

    var payPalClient: PayPalClient?

    var orderID: String? {
        order?.id
    }

    let configManager = CoreConfigManager(domain: "PayPalWeb Payments")
    private var payPalDataCollector: PayPalDataCollector?

    func checkout(
        shouldVault: Bool,
        userAction: PayPalUserAction,
        userIdentity: PayPalUserIdentity?
    ) async throws {
        state.createdOrderResponse = .loading

        guard let client = try await getPayPalClient() else {
            let message = "Error initializing PayPalClient"
            state.createdOrderResponse = .error(message: message)
            throw CheckoutError.clientInitializationFailed(message)
        }
        payPalClient = client

        let urlConfig: PayPalURLConfig
        do {
            urlConfig = try ShopperSessionURLConfigFactory.makeURLConfig()
        } catch {
            state.createdOrderResponse = .error(message: error.localizedDescription)
            throw error
        }

        client.createPayPalSession(
            sessionType: .checkout,
            userIdentity: userIdentity,
            urlConfig: urlConfig,
            userAction: userAction
        )

        async let orderTask = fetchOrder(shouldVault: shouldVault)
        let order = try await orderTask

        state.approveResultResponse = .loading

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            client.start(orderID: order.id) { result in
                switch result {
                case .success(let paypalResult):
                    self.state.approveResultResponse = .loaded(
                        PayPalPaymentState.ApprovalResult(id: paypalResult.orderID, status: "APPROVED")
                    )
                    self.checkoutResult = paypalResult
                    continuation.resume()
                case .failure(let error):
                    if error == PayPalError.checkoutCanceledError {
                        self.state.approveResultResponse = .error(message: "PayPal checkout was canceled.")
                        continuation.resume()
                    } else {
                        self.state.approveResultResponse = .error(message: error.localizedDescription)
                        continuation.resume(throwing: error)
                    }
                }
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
            
            let experience = PayPalExperienceContext(
                returnUrl: "\(appSwitchURL)/success",
                cancelUrl: "\(appSwitchURL)/cancel",
                nativeApp: NativeApp(appUrl: appSwitchURL)
            )

            let attributes: Attributes? = shouldVault ? Attributes(vault: DemoFixtures.vaultAttributes) : nil

            let paypal = PayPalSource(attributes: attributes, experienceContext: experience)
            paymentSource = .paypal(OrderPayPalPaymentSource(paypal: paypal))

            let params = CreateOrderParams(
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
            return order
        } catch {
            state.createdOrderResponse = .error(message: error.localizedDescription)
            throw error
        }
    }

    func paymentButtonTapped(funding: PayPalCheckoutFundingSource) {
        Task {
            do {
                state.approveResultResponse = .loading

                if payPalClient == nil {
                    payPalClient = try await getPayPalClient()
                }
                guard let payPalClient, let orderID = state.createOrder?.id else {
                    state.approveResultResponse = .error(message: "Missing PayPal client or order ID")
                    return
                }

                payPalClient.start(orderID: orderID) { result in
                    switch result {
                    case .success(let paypalResult):
                        self.state.approveResultResponse = .loaded(
                            PayPalPaymentState.ApprovalResult(id: paypalResult.orderID, status: "APPROVED")
                        )
                        self.checkoutResult = paypalResult
                    case .failure(let error):
                        if error == PayPalError.checkoutCanceledError {
                            self.state.approveResultResponse = .error(message: "PayPal checkout was canceled.")
                        } else {
                            self.state.approveResultResponse = .error(message: error.localizedDescription)
                        }
                    }
                }
            } catch {
                state.createdOrderResponse = .error(message: error.localizedDescription)
            }
        }
    }

    func getPayPalClient() async throws -> PayPalClient? {
        do {
            let config = try await configManager.getCoreConfig()
            let payPalClient = PayPalClient(config: config)
            payPalDataCollector = PayPalDataCollector(config: config)
            return payPalClient
        } catch {
            DispatchQueue.main.async {
                self.state.createdOrderResponse = .error(message: error.localizedDescription)
            }
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
        DispatchQueue.main.async {
            switch self.intent {
            case .authorize:
                self.state.authorizedOrderResponse = .loading
            case .capture:
                self.state.capturedOrderResponse = .loading
            }
        }
    }

    private func setOrderCompletionLoadedState(order: Order) {
        DispatchQueue.main.async {
            switch self.intent {
            case .authorize:
                self.state.authorizedOrderResponse = .loaded(order)
            case .capture:
                self.state.capturedOrderResponse = .loaded(order)
            }
        }
    }

    private func setErrorState(message: String) {
        DispatchQueue.main.async {
            switch self.intent {
            case .authorize:
                self.state.authorizedOrderResponse = .error(message: message)
            case .capture:
                self.state.capturedOrderResponse = .error(message: message)
            }
        }
    }

    func resetState() {
        self.state = PayPalPaymentState()
        order = nil
        checkoutResult = nil
    }

    // for testing until singleton router class is implemented
    func handleUniversalLinkReturn(_ url: URL) {
        guard let payPalClient else { return }
        payPalClient.handleReturnURL(url)
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
