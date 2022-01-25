import UIKit

#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal Paysheet to handle PayPal transaction
public class PayPalClient {

    private let config: CoreConfig
    private let returnURL: String
    private let apiClient: APIClient

    /// Initialize a PayPalClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object
    ///   - returnURL: The return URL provided to the PayPal Native UI experience. Used as part of the authentication process to identify your application. This value should match the one set in the `Return URLs` section of your application's dashboard on your [PayPal developer account](https://developer.paypal.com)
    public init(config: CoreConfig, returnURL: String) {
        self.config = config
        self.returnURL = returnURL
        self.apiClient = APIClient(environment: config.environment)
    }

    /// Present PayPal Paysheet and start a PayPal transaction
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    ///   - presentingViewController: the ViewController to present PayPalPaysheet on, if not provided, the Paysheet will be presented on your top-most ViewController
    ///   - completion: Completion block to handle buyer's approval, cancellation, and error.
    public func start(
        request: PayPalRequest,
        presentingViewController: UIViewController? = nil,
        completion: @escaping (PayPalCheckoutResult) -> Void
    ) {
//        CheckoutFlow.set(config: config, returnURL: returnURL)
//
//        CheckoutFlow.start(
//            presentingViewController: presentingViewController,
//            createOrder: { order in
//                order.set(orderId: orderID)
//            },
//            onApprove: { approval in
//                let payPalResult = PayPalResult(
//                    orderID: approval.ecToken,
//                    payerID: approval.payerID
//                )
//                completion(.success(result: payPalResult))
//            },
//            onCancel: {
//                completion(.cancellation)
//            },
//            onError: { errorInfo in
//                completion(.failure(error: PayPalError.nativeCheckoutSDKError(errorInfo)))
//            }
//        )
    }
}
