import UIKit
import PayPalCheckout
import PaymentsCore

/// PayPal Paysheet to handle PayPal transaction
public class PayPalClient {

    public weak var delegate: PayPalDelegate?

    let config: CoreConfig

    let nativeCheckout: CheckoutProtocol

    /// Initialize a PayPalClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    ///   - returnURL: The return URL provided to the PayPal Native UI experience. Used as part of the authentication process to identify your application. This value should match the one set in the `Return URLs` section of your application's dashboard on your [PayPal developer account](https://developer.paypal.com)
    public init(config: CoreConfig) {
        self.config = config
        let nxoConfig = CheckoutConfig(
            clientID: config.clientID, createOrder: nil, onApprove: nil,
                    onShippingChange: nil, onCancel: nil, onError: nil, environment: config.environment.toNativeCheckoutSDKEnvironment())
        self.nativeCheckout = NativeCheckout(nxoConfig: nxoConfig)
    }

    init(config: CoreConfig, checkoutFlow: CheckoutProtocol) {
        self.config = config
        self.nativeCheckout = checkoutFlow
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on, if not provided, the Paysheet will be presented on your top-most ViewController
    ///   - completion: Completion block to handle buyer's approval, cancellation, and error.
    public func start(presentingViewController: UIViewController?, orderID: String, deleagate: PayPalDelegate?){
        self.delegate = deleagate
        DispatchQueue.main.async {
            self.nativeCheckout.start(
                presentingViewController: presentingViewController,
                createOrder: { order in
                    order.set(orderId: orderID)
                },
                onApprove: { approval in
                    self.notifySuccess(for: approval)
                },
                onShippingChange: { shippingChange, shippingChangeAction in
                    self.notifyShippingChange(shippingChange: shippingChange, shippingChangeAction: shippingChangeAction)
                },
                onCancel: {
                    self.notifyCancellation()
                },
                onError: {error in
                    self.notifyFailure(with: error)
                }
            )
        }
    }

    private func notifySuccess(for approval: PayPalCheckout.Approval) {
        delegate?.paypal(didFinishWithResult: approval)
    }

    private func notifyFailure(with errorInfo: PayPalCheckoutErrorInfo) {
        let error = PayPalError.nativeCheckoutSDKError(errorInfo)
        delegate?.paypal(didFinishWithError: error)
    }

    private func notifyCancellation() {
        delegate?.paypalDidCancel()
    }
    private func notifyShippingChange(shippingChange: ShippingChange, shippingChangeAction: ShippingChangeAction) {
        delegate?.paypalDidShippingAddressChange(shippingChange: shippingChange, shippingChangeAction: shippingChangeAction)
    }
}
