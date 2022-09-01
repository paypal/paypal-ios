import UIKit
import PayPalNativeCheckout
import PayPalCheckout
import PaymentsCore

class PayPalViewModel: ObservableObject, PayPalDelegate {

    // MARK: - PayPalDelegate conformance

    func paypalDidShippingAddressChange(
        _ payPalClient: PayPalClient,
        shippingChange: ShippingChange,
        shippingChangeAction: ShippingChangeAction
    ) {
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithResult approvalResult: Approval) {
    }

    func paypal(_ payPalClient: PayPalClient, didFinishWithError error: CoreSDKError) {
    }

    func paypalDidCancel(_ payPalClient: PayPalClient) {
    }

    enum State {
        case initial
        case loading(content: String)
        case payPalReady(title: String, content: String)
        case error(String)
    }

    @Published private(set) var state = State.initial

    private var accessToken = ""

    private var getAccessTokenUseCase = GetAccessToken()
    private var getOrderIdUseCase = GetOrderIdUseCase()
    private var getBillingAgreementToken = GetBillingAgreementToken()
    private var getApprovalSessionTokenUseCase = GetApprovalSessionId()
    private var payPalClient: PayPalClient?

    func getAccessToken() {
        Task {
            state = .loading(content: "Getting access token")
            guard let token = await getAccessTokenUseCase.execute() else {
                state = .error("Failed to fetch access token")
                return
            }
            accessToken = token
            payPalClient = PayPalClient(config: CoreConfig(accessToken: token, environment: PaymentsCore.Environment.sandbox))
            state = .payPalReady(title: "Access Token", content: accessToken)
        }
    }

    func checkoutWithOrder() {
    }

    func checkoutWithOrderId() {
        Task {
            do {
                let orderId = try await getOrderIdUseCase.execute()
                await payPalClient?.start(orderID: orderId, delegate: nil)
            } catch let error {
                state = .error(error.localizedDescription)
            }
        }
    }

    func checkoutWithBillingAgreement() {
        Task {
            do {
                let order = try await getBillingAgreementToken.execute()
            } catch let error {
                state = .error(error.localizedDescription)
            }
        }
    }

    func checkoutWithVault() {
        Task {
            do {
                let vaultSessionId = try await getApprovalSessionTokenUseCase.execute(accessToken: accessToken)
            } catch let error {
                state = .error(error.localizedDescription)
            }
        }
    }
}
