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

    func checkoutWithOrder() async {
        await payPalClient?.start(createOrder: { createOrderAction in
            Task {
                do {
                    let orderId = try await self.getOrderIdUseCase.execute()
                    createOrderAction.set(orderId: orderId)
                } catch let error {
                    self.state = .mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true)
                }
            }
        }, delegate: self)
    }

    func checkoutWithOrderId() async {
        do {
            let orderId = try await getOrderIdUseCase.execute()
            await payPalClient?.start(orderID: orderId)
        } catch let error {
            state = .mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true)
        }
    }

    func checkoutWithBillingAgreement() async {
        await payPalClient?.start(createOrder: { createOrderAction in
            Task {
                do {
                    let order = try await self.getBillingAgreementToken.execute()
                    createOrderAction.set(orderId: order.id)
                } catch let error {
                    self.state = .mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true)
                }
            }
        }, delegate: self)
    }

    func checkoutWithVault() async {
        await payPalClient?.start(createOrder: { createOrderAction in
            Task {
                do {
                    guard let vaultSessionId = try await self.getApprovalSessionTokenUseCase.execute(accessToken: self.accessToken) else {
                        self.state = .mainContent(
                            title: "Error",
                            content: "Error in creating vault session!!",
                            flowComplete: true
                        )

                        return
                    }
                    createOrderAction.set(vaultApprovalSessionID: vaultSessionId)
                } catch let error {
                    self.state = .mainContent(title: "Error", content: "\(error.localizedDescription)", flowComplete: true)
                }
            }
        }, delegate: self)
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
