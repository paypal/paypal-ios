import UIKit
import PayPalNativePayments
import PayPalCheckout
import CorePayments

enum ShippingPreference: String, CaseIterable, Identifiable {
    case noShipping = "NO_SHIPPING"
    case providedAddress = "SET_PROVIDED_ADDRESS"
    case getFromFile = "GET_FROM_FILE"

    var id: ShippingPreference { self }
}

class PayPalViewModel: ObservableObject {

    enum State {
        case initial
        case loading(content: String)
        case mainContent(title: String, content: String, flowComplete: Bool)
        case error(message: String)
    }

    @Published private(set) var state = State.initial
    @Published var selectedMerchantIntegration: MerchantIntegration = .direct
    private var payPalClient: PayPalNativeCheckoutClient?
    private var shippingPreference: ShippingPreference = .noShipping
    private var orderID = ""

    func getClientID() {
        state = .loading(content: "Getting clientID")
        Task {
            guard let clientID = await getClientID() else {
                publishStateToMainThread(.error(message: "Unable to fetch clientID"))
                return
            }
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
        checkout(ShippingPreference.noShipping)
    }

    func checkoutWithProvidedAddress() {
        checkout(ShippingPreference.providedAddress)
    }

    func checkoutWithGetFromFile() {
        checkout(ShippingPreference.getFromFile)
    }

    private func checkout(_ shippingPreference: ShippingPreference) {
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

    private func getOrderID(_ shippingPreference: ShippingPreference) async throws -> String {
        let order = try await DemoMerchantAPI.sharedService.createOrder(
            orderParams: OrderRequestHelpers.getOrderRequest(shippingPreference),
            selectedMerchantIntegration: selectedMerchantIntegration
        )
        return order.id
    }

    func getClientID() async -> String? {
        await DemoMerchantAPI.sharedService.getClientID(
            environment: DemoSettings.environment, selectedMerchantIntegration: selectedMerchantIntegration
        )
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
//                let params = UpdateOrderParams(orderID: orderID, shippingMethods: shippingMethods, amount: amount)
//                try await DemoMerchantAPI.sharedService.updateOrder(params, selectedMerchantIntegration: selectedMerchantIntegration)
                shippingActions.approve()
            } catch let error {
                shippingActions.reject()
                publishStateToMainThread(.mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true))
            }
        }
    }
}
