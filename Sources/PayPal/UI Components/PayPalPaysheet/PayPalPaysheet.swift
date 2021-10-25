import UIKit

#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

/// PayPal Paysheet to handle PayPal transaction
public class PayPalPaysheet: PayPalUI {

    public weak var delegate: PayPalUIDelegate?

    private let config: CoreConfig

    public init(config: CoreConfig) {
        self.config = config
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on
    ///   - orderID: the order ID for the transaction
    public func start(presentingViewController: UIViewController, orderID: String) {
        do {
            let paypalCheckoutConfig = try config.toPayPalCheckoutConfig()
            Checkout.set(config: paypalCheckoutConfig)

            Checkout.start(
                presentingViewController: presentingViewController,
                createOrder: { action in
                    action.set(orderId: orderID)
                },
                onApprove: { approval in
                    self.delegate?.paypal(self, didApproveWith: approval.data.toPayPalResult())
                },
                onCancel: {
                    self.delegate?.paypalDidCancel(self)
                },
                onError: { errorInfo in
                    self.delegate?.paypal(self, didReceiveError: errorInfo.toPayPalSDKError())
                }
            )
        } catch {
            let error = (error as? PayPalSDKError) ?? PayPalError.unknown
            delegate?.paypal(self, didReceiveError: error)
        }
    }
}
