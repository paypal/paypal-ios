import UIKit
import PayPalNativeCheckout
import PayPalCheckout
import PaymentsCore
import Card

class PayPalViewModel: ObservableObject, PayPalDelegate {

    enum State {
        case initial
        case loading(content: String)
        case mainContent(title: String, content: String, flowComplete: Bool)
    }

    @Published private(set) var state = State.initial

    private var accessToken = ""
    private var payPalClient: PayPalClient?

    func getAccessToken() {
        state = .loading(content: "Getting access token")
        Task {
            guard let token = await getAccessToken() else {
                publishStateToMainThread(.mainContent(title: "Access Token", content: accessToken, flowComplete: false))
                return
            }
            accessToken = token
            payPalClient = PayPalClient(config: CoreConfig(accessToken: token, environment: PaymentsCore.Environment.sandbox))
            payPalClient?.delegate = self
            publishStateToMainThread(.mainContent(title: "Access Token", content: accessToken, flowComplete: false))
        }
    }

    func retry() {
        payPalClient = nil
        accessToken = ""
        state = .initial
    }

    func checkoutWithOrderID() {
        state = .loading(content: "Initializing checkout")
        Task {
            do {
                let orderID = try await self.getOrderID()
                await self.payPalClient?.start { createOrderAction in
                    createOrderAction.set(orderId: orderID)
                }
            } catch let error {
                publishStateToMainThread(.mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true))
            }
        }
    }

    private func getOrderID() async throws -> String {
        let order = try await DemoMerchantAPI.sharedService.createOrder(
            orderRequest: OrderRequestHelpers.getOrderParams(shippingChangeEnabled: true)
        )
        return order.id
    }

    func getAccessToken() async -> String? {
        await DemoMerchantAPI.sharedService.getAccessToken(environment: DemoSettings.environment)
    }

    // MARK: - PayPalDelegate conformance

    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalClient,
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

    private func patchAmountAndShippingOptions(
        shippingMethods: [ShippingMethod],
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

    func paypal(_ payPalClient: PayPalClient, didFinishWithResult approvalResult: Approval) {
        publishStateToMainThread(.mainContent(title: "Complete", content: "OrderId: \(approvalResult.data.ecToken)", flowComplete: true))
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
        publishStateToMainThread(.mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true))
    }

    func paypalDidCancel(_ payPalClient: PayPalClient) {
        publishStateToMainThread(.mainContent(title: "Cancelled", content: "User Cancelled", flowComplete: true))
    }

    func paypalDidStart(_ payPalClient: PayPalClient) {
        publishStateToMainThread(.mainContent(title: "Starting", content: "PayPal is about to start", flowComplete: true))
    }

    private func publishStateToMainThread(_ state: State) {
        DispatchQueue.main.async {
            self.state = state
        }
    }
}
