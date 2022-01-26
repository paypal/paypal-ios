import UIKit

#if canImport(PaymentsCore)
import PaymentsCore
import AuthenticationServices
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
    ///   - context: the ASWebAuthenticationPresentationContextProviding conforming ViewController
    ///   - completion: Completion block to handle buyer's approval, cancellation, and error.
    public func start(
        request: PayPalRequest,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (PayPalCheckoutResult) -> Void
    ) {
        let webAuthenticationSession = WebAuthenticationSession()
        let baseURLString = config.environment.payPalBaseURL.absoluteString
        let payPalCheckoutURLString = String(format: "%@/checkoutnow?token=%@", baseURLString, request.orderID)

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString) else {
            // TODO: return error
            return
        }

        guard let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL) else {
            // TODO: return error
            return
        }

        webAuthenticationSession.start(url: payPalCheckoutURLComponents, context: context, callbackURLScheme: returnURL) { url, error in
            if let error = error {
                let result = PayPalCheckoutResult.failure(error: PayPalError.webSessionError(error))
                completion(result)
            }
            if let url = url {
                let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token")
                let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID")

                let result = PayPalCheckoutResult.success(
                    result: PayPalResult(orderID: orderID, payerID: payerID)
                )
                completion(result)
            }
        }
    }

    func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> (URL?) {
        let redirectURLString = String(format: "%@://x-callback-url/paypal-sdk/paypal-checkout", returnURL)
        let redirectQueryItem = URLQueryItem(name: "redirect_uri", value: redirectURLString)
        let nativeXOQueryItem = URLQueryItem(name: "native_xo", value: "1")

        var checkoutURLComponents = URLComponents(url: payPalCheckoutURL, resolvingAgainstBaseURL: false)
        checkoutURLComponents?.queryItems?.append(redirectQueryItem)
        checkoutURLComponents?.queryItems?.append(nativeXOQueryItem)

        return checkoutURLComponents?.url
    }

    private func getQueryStringParameter(url: String, param: String) -> String {
        guard let url = URLComponents(string: url) else {
            return ""
        }
        return url.queryItems?.first { $0.name == param }?.value ?? ""
    }
}
