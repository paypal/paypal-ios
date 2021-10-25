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
    private var paypalCheckoutConfig: CheckoutConfig?

    public init(config: CoreConfig) {
        self.config = config
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on
    ///   - orderID: the order ID for the transaction
    public func start(presentingViewController: UIViewController, orderID: String) {
        do {
            paypalCheckoutConfig = try setPayPalCheckoutConfig(orderID: orderID)
            Checkout.start(presentingViewController: presentingViewController)
        } catch {
            let error = (error as? PayPalSDKError) ?? PayPalError.unknown
            delegate?.paypal(self, didReceiveError: error)
        }
    }

    func setPayPalCheckoutConfig(orderID: String) throws -> CheckoutConfig {
        let paypalCheckoutConfig = try config.toPayPalCheckoutConfig()

        paypalCheckoutConfig.createOrder = { action in
            action.set(orderId: orderID)
        }

        paypalCheckoutConfig.onApprove = { approval in
            self.delegate?.paypal(self, didApproveWith: approval.data.toPayPalResult())
        }

        paypalCheckoutConfig.onCancel = {
            self.delegate?.paypalDidCancel(self)
        }

        paypalCheckoutConfig.onError = { errorInfo in
            self.delegate?.paypal(self, didReceiveError: errorInfo.toPayPalSDKError())
        }

        Checkout.set(config: paypalCheckoutConfig)

        return paypalCheckoutConfig
    }
}
