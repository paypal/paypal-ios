import Foundation
import AuthenticationServices

public class WebAuthenticationSession: NSObject {

    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: ((Bool) -> Void)? = nil,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        let authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: PayPalCoreConstants.callbackURLScheme,
            completionHandler: sessionDidComplete
        )

        authenticationSession.prefersEphemeralWebBrowserSession = true
        authenticationSession.presentationContextProvider = context

        DispatchQueue.main.async {
            // TODO: - Make sessionDidDisplay non-optional after implementing analytics for PayPalWebCheckout
            if let sessionDidDisplay {
                sessionDidDisplay(authenticationSession.start())
            } else {
                authenticationSession.start()
            }
        }
    }
}
