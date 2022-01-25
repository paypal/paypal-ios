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
        let baseURLString = config.environment.baseURL.absoluteString
        let payPalCheckoutURLString = String(format: "%@/checkoutnow?token=%@", baseURLString, request.orderID)
        let payPalCheckoutURL = URL(string: payPalCheckoutURLString)
        let webAuthenticationSession = WebAuthenticationSession()
        
        let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL!)
        webAuthenticationSession.start(
            url: payPalCheckoutURLComponents!,
            callbackURLScheme: returnURL,
            completionHandler: { url, error in
                if let error = error {
                        let result = PayPalCheckoutResult.failure(error: PayPalError.webSessionError(error))
            
                    }
                })
            
    }
    
    func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> (URL?) {
        let redirectURLString = String(format: "%@://x-callback-url/paypal-sdk/paypal-checkout", returnURL)
        let redirectQueryItem = URLQueryItem(name: "redirect_uri", value: redirectURLString)
        let nativeXOQueryItem = URLQueryItem(name: "native_xo", value: "1")
        
        var checkoutURLComponents = URLComponents(url: payPalCheckoutURL, resolvingAgainstBaseURL: false)
        if let currentQueryItems = checkoutURLComponents?.queryItems![0] {
            let queryItems = [currentQueryItems, redirectQueryItem, nativeXOQueryItem]
            checkoutURLComponents?.queryItems = queryItems
            return checkoutURLComponents?.url
        }
        return nil
    }

}
