import UIKit

#if canImport(PaymentsCore)
import PaymentsCore
import AuthenticationServices
#endif

/// PayPal Paysheet to handle PayPal transaction
public class PayPalClient {

    private let config: CoreConfig

    /// Initialize a PayPalClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object

    public init(config: CoreConfig) {
        self.config = config
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
        let payPalCheckoutURLString = "\(baseURLString)/checkoutnow?token=\(request.orderID)"

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
        let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
        else {
            let result = PayPalCheckoutResult.failure(error: PayPalError.payPalURLError)
            completion(result)
            return
        }

        webAuthenticationSession.start(url: payPalCheckoutURLComponents, context: context) { url, error in
            if let error = error {
                let result = PayPalCheckoutResult.failure(error: PayPalError.webSessionError(error))
                completion(result)
            }

            if let url = url {
                guard let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
                let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") else {
                    let result = PayPalCheckoutResult.failure(error: PayPalError.malformedResultError)
                    completion(result)
                    return
                }

                let result = PayPalCheckoutResult.success(
                    result: PayPalResult(orderID: orderID, payerID: payerID)
                )
                completion(result)
            }
        }
    }

    private func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> (URL?) {
        guard let bundleID = Bundle.main.bundleIdentifier else { return nil }
        let redirectURLString = "\(bundleID)://x-callback-url/paypal-sdk/paypal-checkout"
        let redirectQueryItem = URLQueryItem(name: "redirect_uri", value: redirectURLString)
        let nativeXOQueryItem = URLQueryItem(name: "native_xo", value: "1")

        var checkoutURLComponents = URLComponents(url: payPalCheckoutURL, resolvingAgainstBaseURL: false)
        checkoutURLComponents?.queryItems?.append(redirectQueryItem)
        checkoutURLComponents?.queryItems?.append(nativeXOQueryItem)

        return checkoutURLComponents?.url
    }

    private func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first { $0.name == param }?.value
    }
}
