import UIKit

#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

public typealias PayPalCheckoutCompletion = (PayPalCheckoutState) -> Void

/// PayPal Paysheet to handle PayPal transaction
public class PayPalPaysheet {

    private let config: CoreConfig
    private let returnURL: String

    private lazy var paypalCheckoutConfig: CheckoutConfig = {
        CheckoutConfig(clientID: config.clientID, returnUrl: returnURL)
    }()

    private var completion: PayPalCheckoutCompletion?

    public init(config: CoreConfig, returnURL: String) {
        self.config = config
        self.returnURL = returnURL
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on
    ///   - orderID: the order ID for the transaction
    public func start(presentingViewController: UIViewController, orderID: String, completion: PayPalCheckoutCompletion? = nil) {
        self.completion = completion
        setupPayPalCheckoutConfig(orderID: orderID)
        Checkout.start(presentingViewController: presentingViewController)
    }

    func setupPayPalCheckoutConfig(orderID: String) {
        paypalCheckoutConfig.createOrder = { action in
            action.set(orderId: orderID)
        }

        paypalCheckoutConfig.onApprove = { approval in
            self.completion?(.success(result: approval.data.toPayPalResult()))
        }

        paypalCheckoutConfig.onCancel = {
            self.completion?(.cancellation)
        }

        paypalCheckoutConfig.onError = { errorInfo in
            self.completion?(.failure(error: PayPalError.payPalCheckoutError(errorInfo)))
        }

        Checkout.set(config: paypalCheckoutConfig)
    }
}
