import UIKit

@_implementationOnly import PayPalCheckout

#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal Paysheet to handle PayPal transaction
public class PayPalClient {

    public weak var delegate: PayPalDelegate?

    let config: CoreConfig

    // swiftlint:disable identifier_name
    let CheckoutFlow: CheckoutProtocol.Type
    // swiftlint:enable identifier_name

    /// Initialize a PayPalClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    ///   - returnURL: The return URL provided to the PayPal Native UI experience. Used as part of the authentication process to identify your application. This value should match the one set in the `Return URLs` section of your application's dashboard on your [PayPal developer account](https://developer.paypal.com)
    public init(config: CoreConfig) {
        self.config = config
        self.CheckoutFlow = Checkout.self
    }

    init(config: CoreConfig, checkoutFlow: CheckoutProtocol.Type) {
        self.config = config
        self.CheckoutFlow = checkoutFlow
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on, if not provided, the Paysheet will be presented on your top-most ViewController
    ///   - completion: Completion block to handle buyer's approval, cancellation, and error.
    public func start(request: PayPalRequest, presentingViewController: UIViewController? = nil) {
        CheckoutFlow.set(config: config)

        CheckoutFlow.start(
            presentingViewController: presentingViewController,
            createOrder: { order in
                order.set(orderId: request.orderID)
            },
            onApprove: { approval in
                self.notifySuccess(for: approval)
            },
            onCancel: {
                self.notifyCancellation()
            },
            onError: { errorInfo in
                self.notifyFailure(with: errorInfo)
            }
        )
    }

    private func notifySuccess(for approval: PayPalCheckoutApprovalData) {
        let payPalResult = PayPalResult(orderID: approval.ecToken, payerID: approval.payerID)
        delegate?.paypal(self, didFinishWithResult: payPalResult)
    }

    private func notifyFailure(with errorInfo: PayPalCheckoutErrorInfo) {
        let error = PayPalError.nativeCheckoutSDKError(errorInfo)
        delegate?.paypal(self, didFinishWithError: error)
    }

    private func notifyCancellation() {
        delegate?.paypalDidCancel(self)
    }
}
