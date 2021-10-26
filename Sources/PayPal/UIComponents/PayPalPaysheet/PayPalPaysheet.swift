import UIKit

#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

public typealias PayPalCheckoutCompletion = (PayPalCompletionState) -> Void

/// PayPal Paysheet to handle PayPal transaction
public class PayPalPaysheet {

    private let config: CoreConfig
    private let returnURL: String

    lazy var paypalCheckoutConfig: CheckoutConfig = {
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
    public func start(presentingViewController: UIViewController, orderID: String, completion: PayPalCheckoutCompletion? = nil) {
        setupPayPalCheckoutConfig(orderID: orderID, completion: completion)
        Checkout.start(presentingViewController: presentingViewController)
    }

    func setupPayPalCheckoutConfig(orderID: String, completion: PayPalCheckoutCompletion? = nil) {
        paypalCheckoutConfig.createOrder = { action in
            action.set(orderId: orderID)
        }

        paypalCheckoutConfig.onApprove = { approval in
            completion?(.success(result: approval.data.toPayPalResult()))
        }

        paypalCheckoutConfig.onCancel = {
            completion?(.cancellation)
        }

        paypalCheckoutConfig.onError = { errorInfo in
            completion?(.failure(error: PayPalError.payPalCheckoutError(errorInfo)))
        }

        Checkout.set(config: paypalCheckoutConfig)
    }
}
