import UIKit
#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

// TODO: Add documentation to all of this
public class PayPalInterface {

    public weak var delegate: PayPalInterfaceDelegate?

    private let config: CoreConfig

    // TODO: find a nicer way to do this instead of try/throwing
    public init(config: CoreConfig) throws {
        self.config = config

        Checkout.set(config: try config.toPayPalCheckoutConfig())
    }

    public func startPayPalCheckout(presentingViewController: UIViewController, orderID: String) {
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
    }
}
