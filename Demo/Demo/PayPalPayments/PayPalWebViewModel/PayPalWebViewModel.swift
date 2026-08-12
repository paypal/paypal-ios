import Foundation
import CorePayments
import PayPalPayments
import FraudProtection

extension PayPalUserAction {

    var parameterTitle: String {
        switch self {
        case .continue:
            return "CONTINUE"
        case .payNow:
            return "PAY_NOW"
        case .setupNow:
            return "SETUP_NOW"
        }
    }
}

@MainActor
class PayPalWebViewModel: ObservableObject {

    private enum DemoFixtures {
        static let vaultAttributes = Vault(storeInVault: "ON_SUCCESS", usageType: "MERCHANT", customerType: "CONSUMER")
    }

    @Published var state = PayPalPaymentState()
    @Published var intent: Intent = .authorize
    @Published var order: Order?
    @Published var checkoutResult: PayPalCheckoutResult?

    /// Callback host for app switch, resolved from the environment selected in Demo settings.
    /// Read as a computed property so switching environment at runtime is picked up.
    var appSwitchURL: String { DemoSettings.environment.returnBaseURL }

    var payPalClient: PayPalClient?

    var orderID: String? {
        order?.id
    }

    let configManager = CoreConfigManager(domain: "PayPalWeb Payments")
    private var payPalDataCollector: PayPalDataCollector?

    func checkout(
        shouldVault: Bool,
        userAction: PayPalUserAction,
        userIdentity: PayPalUserIdentity?,
        amount: String
    ) async throws {
        state.createdOrderResponse = .loading

        let client = makePayPalClient()
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

        async let orderTask = fetchOrder(shouldVault: shouldVault, amount: amount, userAction: userAction)
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
    private func fetchOrder(shouldVault: Bool, amount: String, userAction: PayPalUserAction) async throws -> Order {
        do {
            let defaultAmount = "10.00"
            let amountRequest = Amount(
                currencyCode: "USD",
                value: amount.isEmpty ? defaultAmount : amount
            )

            var paymentSource: OrderPaymentSource?

            let experience = PayPalExperienceContext(
                returnUrl: "\(appSwitchURL)/success",
                cancelUrl: "\(appSwitchURL)/cancel",
                userAction: userAction.parameterTitle,
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
            let order = try await DemoMerchantAPI.shared.createOrder(
                orderParams: params,
                integration: DemoSettings.merchantIntegration
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
        state.approveResultResponse = .loading

        if payPalClient == nil {
            payPalClient = makePayPalClient()
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
    }

    func makePayPalClient() -> PayPalClient {
        let config = configManager.getCoreConfig()
        let payPalClient = PayPalClient(config: config)
        payPalDataCollector = PayPalDataCollector(config: config)
        return payPalClient
    }

    func completeTransaction() async throws {
        do {
            setLoadingState()
            if let orderID = state.createOrder?.id {
                let payPalClientMetadataID = payPalDataCollector?.collectDeviceData()
                let order = try await DemoMerchantAPI.shared.completeOrder(
                    intent: intent,
                    orderID: orderID,
                    clientMetadataID: payPalClientMetadataID
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
