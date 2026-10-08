import Foundation
import PayPalPayments
import FraudProtection

@Observable
@MainActor
class PayPalPaymentViewModel {
    
    let api = DemoMerchantAPI.shared
    let integration = DemoSettings.merchantIntegration

    var orderIntent: Intent = .authorize
    var createOrderState: AsyncState<Order> = .idle
    
    func createOrder(using request: DemoCreateOrderRequest) {
        orderIntent = request.intent
        createOrderState = .loading
        Task {
            let params = makePayPalOrderParams(request: request)
            do {
                let order = try await api.createOrder(orderParams: params, integration: integration)
                createOrderState = .loaded(order)
            } catch {
                createOrderState = .error(message: error.localizedDescription)
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
}
