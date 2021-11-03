import UIKit

@_implementationOnly import PayPalCheckout

#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal Paysheet to handle PayPal transaction
public class PayPalClient {

    private let config: CoreConfig
    private let returnURL: String

    // TODO: I don't think we can override a lazy var in our tests ... or can we?
    lazy var nativeCheckoutSDKConfig: CheckoutConfig = {
        CheckoutConfig(
            clientID: config.clientID,
            returnUrl: returnURL,
            environment: config.environment.toNativeCheckoutSDKEnvironment()
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
    public func start(
        orderID: String,
        presentingViewController: UIViewController? = nil,
        completion: @escaping (PayPalCheckoutResult) -> Void
    ) {
        nativeCheckoutSDKConfig.createOrder = { action in
            action.set(orderId: orderID)
        }

        nativeCheckoutSDKConfig.onApprove = { approval in
            let payPalResult = PayPalResult(orderID: approval.data.ecToken, payerID: approval.data.payerID)
            completion(.success(result: payPalResult))
        }

        nativeCheckoutSDKConfig.onCancel = {
            completion(.cancellation)
        }

        nativeCheckoutSDKConfig.onError = { errorInfo in
            completion(.failure(error: PayPalError.nativeCheckoutSDKError(errorInfo)))
        }

        Checkout.set(config: nativeCheckoutSDKConfig)

        Checkout.start(presentingViewController: presentingViewController)
    }
}

protocol PayPalCheckoutConfigProtocol {

    var createOrder: CheckoutConfig.CreateOrderCallback? { get set }

    var onApprove: CheckoutConfig.ApprovalCallback? { get set }

    var onCancel: CheckoutConfig.CancelCallback? { get set }

    var onError: CheckoutConfig.ErrorCallback? { get set }
}

extension PayPalCheckout.CheckoutConfig: PayPalCheckoutConfigProtocol {

    // create an mini initializer that only uses 3 params we need, and have it internally call the big initializer

}
