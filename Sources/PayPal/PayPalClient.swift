import UIKit

@_implementationOnly import PayPalCheckout

#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal Paysheet to handle PayPal transaction
public class PayPalClient {

    private let config: CoreConfig
    private let returnURL: String

    // swiftlint:disable identifier_name
    private let CheckoutFlow: PayPalUIFlow.Type
    // swiftlint:enable identifier_name

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
    public convenience init(config: CoreConfig, returnURL: String) {
        self.init(config: config, returnURL: returnURL, checkoutFlow: Checkout.self)
    }

    init(config: CoreConfig, returnURL: String, checkoutFlow: PayPalUIFlow.Type) {
        self.config = config
        self.returnURL = returnURL
        self.CheckoutFlow = checkoutFlow
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
            completion(.failure(error: PayPalError.cancelled))
        }

        nativeCheckoutSDKConfig.onError = { errorInfo in
            completion(.failure(error: PayPalError.nativeCheckoutSDKError(errorInfo)))
        }

        CheckoutFlow.set(config: nativeCheckoutSDKConfig)

        CheckoutFlow.start(
            presentingViewController: presentingViewController,
            createOrder: nil,
            onApprove: nil,
            onCancel: nil,
            onError: nil
        )
    }
}
