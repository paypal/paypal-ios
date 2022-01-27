import UIKit
import AuthenticationServices

#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// PayPal Client to handle PayPal flow
public class PayPalClient {

    private let config: CoreConfig

    /// Initialize a PayPalClient to process PayPal transaction
    /// - Parameters:
    ///   - config: The CoreConfig object

    public init(config: CoreConfig) {
        self.config = config
    }

    /// Launch the PayPal web flow
    /// - Parameters:
    ///   - request: the PayPalRequest for the transaction
    ///   - context: the ASWebAuthenticationPresentationContextProviding protocol conforming ViewController
    ///   - completion: Completion handler for start, which contains data of the order if success, or an error if failure
    public func start(
        request: PayPalRequest,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (Result<PayPalResult, CoreSDKError>) -> Void
    ) {
        start(request: request, context: context, webAuthenticationSession: WebAuthenticationSession(), completion: completion)
    }

    /// Internal function for testing the start function
    func start(
        request: PayPalRequest,
        context: ASWebAuthenticationPresentationContextProviding,
        webAuthenticationSession: WebAuthenticationSession,
        completion: @escaping (Result<PayPalResult, CoreSDKError>) -> Void
    ) {
        let baseURLString = config.environment.payPalBaseURL.absoluteString
        let payPalCheckoutURLString = "\(baseURLString)/checkoutnow?token=\(request.orderID)"

        guard let payPalCheckoutURL = URL(string: payPalCheckoutURLString),
        let payPalCheckoutURLComponents = payPalCheckoutReturnURL(payPalCheckoutURL: payPalCheckoutURL)
        else {
            completion(.failure(PayPalClientError.payPalURLError))
            return
        }

        webAuthenticationSession.start(url: payPalCheckoutURLComponents, context: context) { url, error in
            if let error = error {
                completion(.failure(PayPalClientError.webSessionError(error)))
            }

            if let url = url {
                guard let orderID = self.getQueryStringParameter(url: url.absoluteString, param: "token"),
                let payerID = self.getQueryStringParameter(url: url.absoluteString, param: "PayerID") else {
                    completion(.failure(PayPalClientError.malformedResultError))
                    return
                }

                let result = PayPalResult(orderID: orderID, payerID: payerID)
                completion(.success(result))
            }
        }
    }

    func payPalCheckoutReturnURL(payPalCheckoutURL: URL) -> URL? {
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
