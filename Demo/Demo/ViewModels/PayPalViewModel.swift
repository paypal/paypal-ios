import UIKit
import PayPalNativeCheckout
import PayPalCheckout
import PaymentsCore

class PayPalViewModel: ObservableObject, PayPalDelegate {

    enum State {
        case initial
        case loading(content: String)
        case mainContent(title: String, content: String, flowComplete: Bool)
    }

    @Published private(set) var state = State.initial

    private var accessToken = ""

    private var getAccessTokenUseCase = GetAccessToken()
    private var getOrderIdUseCase = GetOrderIdUseCase()
    private var getBillingAgreementToken = GetBillingAgreementToken()
    private var getBATokenWithoutPurchaseUseCase = GetBATokenWithoutPurchase()
    private var getApprovalSessionTokenUseCase = GetApprovalSessionId()
    private var getOrderRequestUseCase = GetOrderRequestUseCase()
    private var payPalClient: PayPalClient?

    func getAccessToken() {
        Task {
            state = .loading(content: "Getting access token")
            guard let token = await getAccessTokenUseCase.execute() else {
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
            let orderRequest = self.getOrderRequestUseCase.execute()
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.create(order: orderRequest)
            }
        }
    }

    func checkoutWithOrderId() {
        startNativeCheckout {
            let orderId = try await self.getOrderIdUseCase.execute()
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(orderId: orderId)
            }
        }
    }

    func checkoutWithBillingAgreement() {
        startNativeCheckout {
            let order = try await self.getBillingAgreementToken.execute()
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(billingAgreementToken: order.id)
            }
        }
    }

    func checkoutBAWithoutPurchase() {
        startNativeCheckout {
            let baToken = try await self.getBATokenWithoutPurchaseUseCase.execute(accessToken: self.accessToken)
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(billingAgreementToken: baToken)
            }
        }
    }

    func checkoutWithVault() {
        startNativeCheckout {
            guard let vaultSessionId = try await self.getApprovalSessionTokenUseCase.execute(accessToken: self.accessToken) else {
                self.state = .mainContent(
                    title: "Error",
                    content: "Error in creating vault session!!",
                    flowComplete: true
                )

                return
            }
            await self.payPalClient?.start { createOrderAction in
                createOrderAction.set(vaultApprovalSessionID: vaultSessionId)
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

    // MARK: - PayPalDelegate conformance

    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) {
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
