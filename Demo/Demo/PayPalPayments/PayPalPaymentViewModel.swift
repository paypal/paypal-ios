import Foundation
import PayPalPayments
import CorePayments
import FraudProtection

@Observable
@MainActor
class PayPalPaymentViewModel {
    
    let api = DemoMerchantAPI.shared

    var orderIntent: Intent = .authorize
    
    var createOrderState: AsyncState<Order> = .idle
    var approveOrderState: AsyncState<PayPalCheckoutResult> = .idle
    var completeOrderState: AsyncState<Order> = .idle

    private let payPalClient: PayPalClient
    private let payPalDataCollector: PayPalDataCollector

    init() {
        let configManager = CoreConfigManager(domain: "PayPalWeb Payments")
        let config = configManager.getCoreConfig()

        payPalClient = PayPalClient(config: config)
        payPalDataCollector = PayPalDataCollector(config: config)
    }
    
    // this is used to track changes and drive the scroll-to-bottom animation
    var stateHash: Int {
        return hash(createOrderState, approveOrderState, completeOrderState)
    }

    func createOrder(using request: DemoCreateOrderRequest) {
        orderIntent = request.intent
        createOrderState = .loading
        Task {
            let params = makePayPalOrderParams(request: request)
            do {
                let order = try await api.createOrder(orderParams: params)
                createOrderState = .loaded(order)
            } catch {
                createOrderState = .error(message: error.localizedDescription)
            }
        }
    }
    
    func approveOrder(using request: DemoApproveOrderWithPayPalRequest) {
        guard let orderID = createOrderState.value?.id else {
            approveOrderState = .error(message: "Order ID Required.")
            return
        }
        
        approveOrderState = .loading
        Task {
            do {
                try initiatePayPalSession(using: request)
                let result = try await startPayPalCheckout(withOrderID: orderID)
                approveOrderState = .loaded(result)
            } catch {
                if error as? CoreSDKError == PayPalError.checkoutCanceledError {
                    approveOrderState = .error(message: "PayPal checkout was canceled.")
                } else {
                    approveOrderState = .error(message: error.localizedDescription)
                }
            }
        }
    }
    
    func completeOrder() {
        guard let orderID = createOrderState.value?.id else {
            completeOrderState = .error(message: "Order ID Required.")
            return
        }
        
        completeOrderState = .loading
        Task {
            do {
                let clientMetadataID = payPalDataCollector.collectDeviceData()
                let completedOrder: Order
                switch orderIntent {
                case .capture:
                    completedOrder = try await api.captureOrder(
                        orderID: orderID,
                        clientMetadataID: clientMetadataID
                    )
                case .authorize:
                    completedOrder = try await api.authorizeOrder(
                        orderID: orderID,
                        clientMetadataID: clientMetadataID
                    )
                }
                completeOrderState = .loaded(completedOrder)
            } catch {
                print("Error capturing order: \(error.localizedDescription)")
                completeOrderState = .error(message: error.localizedDescription)
            }
        }
    }

    private func makePayPalOrderParams(request: DemoCreateOrderRequest) -> CreateOrderParams {
        let defaultAmount = "10.00"
        let value = request.amount.isEmpty ? defaultAmount : request.amount
        let amountRequest = Amount(currencyCode: "USD", value: value)
        
        let appSwitchURL = DemoSettings.environment.returnBaseURL
        let experience = PayPalExperienceContext(
            returnUrl: "\(appSwitchURL)/success",
            cancelUrl: "\(appSwitchURL)/cancel",
            nativeApp: NativeApp(appUrl: appSwitchURL)
        )
        
        var attributes: Attributes?
        if request.shouldVault {
            let vaultAttributes =
                Vault(storeInVault: "ON_SUCCESS", usageType: "MERCHANT", customerType: "CONSUMER")
            attributes = Attributes(vault: vaultAttributes)
        }
        
        let paypal = PayPalSource(attributes: attributes, experienceContext: experience)
        let paymentSource = OrderPaymentSource.paypal(OrderPayPalPaymentSource(paypal: paypal))
        return CreateOrderParams(
            intent: orderIntent.rawValue,
            purchaseUnits: [PurchaseUnit(amount: amountRequest)],
            paymentSource: paymentSource
        )
    }
    
    private func initiatePayPalSession(using request: DemoApproveOrderWithPayPalRequest) throws {
        let urlConfig: PayPalURLConfig
        do {
            urlConfig = try ShopperSessionURLConfigFactory.makeURLConfig()
        } catch {
            throw error
        }
        let userIdentity = UserIdentityFactory.makeUserIdentity(
            selection: request.userIdentity,
            email: request.email,
            phone: request.phone,
            ssid: request.ssid
        )
        payPalClient.createPayPalSession(
            sessionType: .checkout,
            userIdentity: userIdentity,
            urlConfig: urlConfig,
            userAction: request.userAction
        )
    }
    
    private func startPayPalCheckout(withOrderID orderID: String) async throws -> PayPalCheckoutResult {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<PayPalCheckoutResult, Error>) in
            payPalClient.start(orderID: orderID) { result in
                switch result {
                case .success(let result):
                    continuation.resume(returning: result)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // for testing until singleton router class is implemented
    func handleUniversalLink(_ url: URL) {
        payPalClient.handleReturnURL(url)
    }
}
