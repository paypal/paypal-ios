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

    @Published private(set) var state = State.mainContent(title: "test", content: "test", flowComplete: true)
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

    func checkoutWithOrder() {
        startNativeCheckout {
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.create(order: OrderRequestHelpers.createOrderRequest())
            }
        }
    }

    func checkoutWithOrderID() {
        startNativeCheckout {
            let orderID = try await self.getOrderIDWithFixedShipping()
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(orderId: orderID)
            }
        }
    }

    func checkoutWithBillingAgreement() {
        startNativeCheckout {
            let order = try await self.getBillingAgreementToken()
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(billingAgreementToken: order.id)
            }
        }
    }

    func checkoutBAWithoutPurchase() {
        startNativeCheckout {
            let billingAgreementToken = try await self.getBillingAgreementTokenWithoutPurchase(
                accessToken: self.accessToken)
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(billingAgreementToken: billingAgreementToken)
            }
        }
    }

    func checkoutWithVault() {
        startNativeCheckout {
            guard let vaultSessionID = try await self.getApprovalSessionID() else {
                self.state = .mainContent(
                    title: "Error",
                    content: "Error in creating vault session!!",
                    flowComplete: true
                )

                return
            }
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(vaultApprovalSessionID: vaultSessionID)
            }
        }
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

    func getOrderIDWithFixedShipping() async throws -> String {
        let order = try await DemoMerchantAPI.sharedService.createOrder(
            orderParams: OrderRequestHelpers.requestWithFixedShipping
        )
        return order.id
    }

    func getBillingAgreementToken() async throws -> Order {
        return try await DemoMerchantAPI.sharedService.createOrder(
            orderParams: OrderRequestHelpers.billingAgreementTokenRequest
        )
    }

    func getBillingAgreementTokenWithoutPurchase(accessToken: String) async throws -> String {
        let baToken = try await DemoMerchantAPI.sharedService.createBillingAgreementToken(
            accessToken: accessToken,
            billingAgremeentTokenRequest: OrderRequestHelpers.billingAgreementWithoutPaymentRequest
        )
        return baToken.tokenID
    }

    func getApprovalSessionID() async throws -> String? {
        let vaultSessionID = try await DemoMerchantAPI.sharedService.createApprovalSessionID(
            accessToken: self.accessToken,
            approvalSessionRequest: OrderRequestHelpers.approvalSessionRequest
        )

        let approvalSessionIDLink = vaultSessionID.links.first { $0.rel == "approve" }
        if let hrefLink = approvalSessionIDLink?.href {
            return URLComponents(string: hrefLink)?.queryItems?.first { $0.name == "approval_session_id" }?.value
        }
        return nil
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
        state = .mainContent(
            title: "Approved",
            content: "OrderID: \(approvalResult.data.ecToken)\nPayerID: \(approvalResult.data.payerID)",
            flowComplete: true
        )
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
