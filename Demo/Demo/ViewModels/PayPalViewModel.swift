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
        Task {
            state = .loading(content: "Getting access token")
            guard let token = await getAccessToken() else {
                state = .mainContent(title: "Error", content: "Failed to fetch access token", flowComplete: true)

                return
            }
            accessToken = token
            payPalClient = PayPalClient(config: CoreConfig(accessToken: token, environment: PaymentsCore.Environment.sandbox))
            payPalClient?.delegate = self
            state = .mainContent(title: "Access Token", content: accessToken, flowComplete: false)
        }
    }

    func retry() {
        payPalClient = nil
        accessToken = ""
        state = .initial
    }

    func checkoutWithOrderID() {
        startNativeCheckout {
            let orderID = try await self.getOrderIDWithFixedShipping()
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(orderId: orderID)
            }
        }
    }

    private func getOrderIDWithFixedShipping() async throws -> String {
        let order = try await DemoMerchantAPI.sharedService.createOrder(
            orderParams: OrderRequestHelpers.requestWithFixedShipping
        )
        return order.id
    }

    private func startNativeCheckout(withAction action: @escaping () async throws -> Void) {
        state = .loading(content: "Initializing checkout")
        Task {
            do {
                try await action()
            } catch let error {
                self.state = .mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true)
            }
        }
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
        // TODO: add required functionality while doing patch or updating order
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithResult approvalResult: Approval) {
        state = .mainContent(title: "Complete", content: "OrderId: \(approvalResult.data.ecToken)", flowComplete: true)
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
        state = .mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true)
    }

    func paypalDidCancel(_ payPalClient: PayPalClient) {
        state = .mainContent(title: "Cancelled", content: "User Cancelled", flowComplete: true)
    }

    func paypalDidStart(_ payPalClient: PayPalClient) {
        state = .mainContent(title: "Starting", content: "PayPal is about to start", flowComplete: true)
    }
}
