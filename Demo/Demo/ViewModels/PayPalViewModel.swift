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
    private var payPalClient: PayPalNativeCheckoutClient?
    private var shippingPreference: OrderApplicationContext.ShippingPreference = .noShipping
    private var orderID = ""
    private var clientID = ""

    func getClientID() {
        state = .loading(content: "Getting clientID")
        Task {
            guard let clientID = await getClientID() else {
                publishStateToMainThread(.mainContent(title: "ClientID", content: clientID, flowComplete: false))
                return
            }
            self.clientID = clientID
            payPalClient = PayPalNativeCheckoutClient(config: CoreConfig(clientID: clientID, environment: CorePayments.Environment.sandbox))
            payPalClient?.delegate = self
            payPalClient?.shippingDelegate = self
            publishStateToMainThread(.mainContent(title: "ClientID", content: clientID, flowComplete: false))
        }
    }

    func retry() {
        payPalClient = nil
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
                orderID = try await self.getOrderID(shippingPreference)
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

    func getClientID() async -> String? {
        await DemoMerchantAPI.sharedService.getClientID(environment: DemoSettings.environment)
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
}

extension PayPalViewModel: PayPalNativeShippingDelegate {
    
    func paypal(
        _ payPalClient: PayPalNativeCheckoutClient,
        didShippingAddressChange shippingAddress: PayPalNativeShippingAddress,
        withAction shippingActions: PayPalNativePaysheetActions
    ) {
        publishStateToMainThread(.mainContent(title: "User action", content: "Shipping address changed", flowComplete: false))
        if shippingAddress.adminArea1?.isEmpty ?? true || shippingAddress.adminArea1 == "NV" {
            shippingActions.reject()
        } else {
            shippingActions.approve()
        }
    }
    
    func paypal(
        _ payPalClient: PayPalNativeCheckoutClient,
        didShippingMethodChange shippingMethod: PayPalNativeShippingMethod,
        withAction shippingActions: PayPalNativePaysheetActions
    ) {
        publishStateToMainThread(.mainContent(title: "User action", content: "Shipping method changed", flowComplete: false))
        Task {
            do {
                let shippingMethods = OrderRequestHelpers.getShippingMethods(selectedID: shippingMethod.id)
                let amount = OrderRequestHelpers.getAmount(shipping: Double(shippingMethod.value ?? "0.0") ?? 0.0)
                let params = UpdateOrderParams(orderID: orderID, shippingMethods: shippingMethods, amount: amount)
                try await DemoMerchantAPI.sharedService.updateOrder(params)
                shippingActions.approve()
            } catch let error {
                shippingActions.reject()
                publishStateToMainThread(.mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true))
            }
        }
    }
}
