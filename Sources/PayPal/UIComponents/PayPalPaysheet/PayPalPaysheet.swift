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
    private let returnURL: String

    private lazy var paypalCheckoutConfig: CheckoutConfig = {
        CheckoutConfig(clientID: config.clientID, returnUrl: returnURL)
    }()

    public init(config: CoreConfig, returnURL: String) {
        self.config = config
        self.returnURL = returnURL
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on
    ///   - orderID: the order ID for the transaction
    public func start(presentingViewController: UIViewController, orderID: String) {
        setupPayPalCheckoutConfig(orderID: orderID)
        Checkout.start(presentingViewController: presentingViewController)
    }

    func setupPayPalCheckoutConfig(orderID: String) {
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
            self.delegate?.paypal(self, didReceiveError: PayPalError.payPalCheckoutError(errorInfo))
        }

        Checkout.set(config: paypalCheckoutConfig)
    }
}
