import UIKit

#if canImport(PaymentsCore)
import PaymentsCore
@_implementationOnly import PayPalCheckout
#endif

public typealias PayPalCheckoutCompletion = (PayPalCheckoutResult) -> Void

/// PayPal Paysheet to handle PayPal transaction
public class PayPalClient {

    private let config: CoreConfig
    private let returnURL: String

    lazy var paypalCheckoutConfig: CheckoutConfig = {
        CheckoutConfig(
            clientID: config.clientID,
            returnUrl: returnURL,
            environment: config.environment.toPayPalCheckoutEnvironment()
        )
    }()

    /// Initialize a PayPalClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    ///   - returnURL: The return URL provided to the PayPal Native UI experience. Used as part of the authentication process to identify your application. This value should match the one set in the `Return URLs` section of your application's dashboard on your [PayPal developer account](https://developer.paypal.com)
    public init(config: CoreConfig, returnURL: String) {
        self.config = config
        self.returnURL = returnURL
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - orderID: the order ID for the transaction
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on, if not provided, the Paysheet will be presented on your top-most ViewController
    ///   - completion: Completion block to handle buyer's approval, cancellation, and error.
    public func start(orderID: String, presentingViewController: UIViewController? = nil, completion: PayPalCheckoutCompletion? = nil) {
        setupPayPalCheckoutConfig(orderID: orderID, completion: completion)
        Checkout.start(presentingViewController: presentingViewController)
    }

    private func setupPayPalCheckoutConfig(orderID: String, completion: PayPalCheckoutCompletion? = nil) {
        paypalCheckoutConfig.createOrder = { action in
            action.set(orderId: orderID)
        }

        paypalCheckoutConfig.onApprove = { approval in
            let payPalResult = PayPalResult(orderID: approval.data.ecToken, payerID: approval.data.payerID)
            completion?(.success(result: payPalResult))
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
