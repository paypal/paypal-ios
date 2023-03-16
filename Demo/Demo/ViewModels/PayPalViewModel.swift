import UIKit
import PayPalNativePayments
import PayPalCheckout
import CorePayments

class PayPalViewModel: ObservableObject {

    enum State {
        case initial
        case loading(content: String)
        case mainContent(title: String, content: String, flowComplete: Bool)
    }

    @Published private(set) var state = State.initial
    private var accessToken = ""
    private var payPalClient: PayPalNativeCheckoutClient?
    private var shippingPreference: OrderApplicationContext.ShippingPreference = .noShipping

    func getAccessToken() {
        state = .loading(content: "Getting access token")
        Task {
            guard let token = await getAccessToken() else {
                publishStateToMainThread(.mainContent(title: "Access Token", content: accessToken, flowComplete: false))
                return
            }
            accessToken = token
            payPalClient = PayPalNativeCheckoutClient(config: CoreConfig(accessToken: token, environment: CorePayments.Environment.sandbox))
            payPalClient?.delegate = self
            publishStateToMainThread(.mainContent(title: "Access Token", content: accessToken, flowComplete: false))
        }
    }

    func retry() {
        payPalClient = nil
        accessToken = ""
        state = .initial
        shippingPreference = .noShipping
    }

    func checkoutWithNoShipping() {
        checkout(.noShipping)
    }

    func checkoutWithProvidedAddress() {
        checkout(.setProvidedAddress)
    }

    func checkoutWithGetFromFile() {
        checkout(.getFromFile)
    }

    private func checkout(_ shippingPreference: OrderApplicationContext.ShippingPreference) {
        state = .loading(content: "Initializing checkout")
        Task {
            do {
                let orderID = try await self.getOrderID(shippingPreference)
                self.shippingPreference = shippingPreference

                let request = PayPalNativeCheckoutRequest(orderID: orderID)
                await self.payPalClient?.start(request: request)
            } catch let error {
                publishStateToMainThread(.mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true))
            }
        }
    }

    private func getOrderID(_ shippingPreference: OrderApplicationContext.ShippingPreference) async throws -> String {
        let order = try await DemoMerchantAPI.sharedService.createOrder(
            orderRequest: OrderRequestHelpers.getOrderRequest(shippingPreference)
        )
        return order.id
    }

    func getAccessToken() async -> String? {
        await DemoMerchantAPI.sharedService.getAccessToken(environment: DemoSettings.environment)
    }


    private func patchAmountAndShippingOptions(
        shippingMethods: [PayPalCheckout.ShippingMethod],
        action: ShippingChangeAction
    ) {
        let selectedMethod = shippingMethods.first { $0.selected }
        let selectedMethodPrice = Double(selectedMethod?.amount?.value ?? "0") ?? 0
        let newTotal = String(OrderRequestHelpers.orderAmount + selectedMethodPrice)

        let patchRequest = PatchRequest()

        patchRequest.replace(amount: PayPalCheckout.PurchaseUnit.Amount(currencyCode: .usd, value: newTotal))
        patchRequest.replace(shippingOptions: shippingMethods)

        action.patch(request: patchRequest) { _, _ in }
    }

    private func publishStateToMainThread(_ state: State) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
}

extension PayPalViewModel: PayPalNativeCheckoutDelegate {

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativeCheckoutResult) {
        publishStateToMainThread(.mainContent(title: "Complete", content: "OrderId: \(result.orderID)", flowComplete: true))
    }

    func paypal(_ payPalClient: PayPalNativeCheckoutClient, didFinishWithError error: CoreSDKError) {
        publishStateToMainThread(.mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true))
    }

    func paypalDidCancel(_ payPalClient: PayPalNativeCheckoutClient) {
        publishStateToMainThread(.mainContent(title: "Cancelled", content: "User Cancelled", flowComplete: true))
    }

    func paypalWillStart(_ payPalClient: PayPalNativeCheckoutClient) {
        publishStateToMainThread(.mainContent(title: "Starting", content: "PayPal is about to start", flowComplete: true))
    }
    
    // Non-ambiguous name for ShippingAddress?
    func onShippingAddressChanged(_ payPalClient: PayPalNativeCheckoutClient, shippingAddress: PayPalNativePayments.ShippingAddress) {
        // TODO
        print(shippingAddress)
    }
    
    func onShippingMethodChanged(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient, shippingMethod: PayPalNativePayments.ShippingMethod) {
        // TODO
        print(shippingMethod)
    }
    
    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalNativeCheckoutClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) {
        switch shippingChange.type {
        case .shippingAddress:
            // If user selected new address, we generate new shipping methods
            let availableShippingMethods = OrderRequestHelpers.getShippingMethods(baseValue: Int.random(in: 0..<6))
            // If shipping methods are available, then patch order with the new shipping methods and new amount
            patchAmountAndShippingOptions(
                shippingMethods: availableShippingMethods,
                action: shippingChangeAction
            )

        case .shippingMethod:
            // If user selected new method, we patch the selected shipping method + amount
            patchAmountAndShippingOptions(
                shippingMethods: shippingChange.shippingMethods,
                action: shippingChangeAction
            )

        @unknown default:
            break
        }
    }
}
