import Foundation
import AuthenticationServices

@_documentation(visibility: private)
public class WebAuthenticationSession: NSObject {

    public func start(
        url: URL,
        callbackURLScheme: String = PayPalCoreConstants.callbackURLScheme,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        let authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: callbackURLScheme,
            completionHandler: sessionDidComplete
        )

        authenticationSession.presentationContextProvider = context

        DispatchQueue.main.async {
            sessionDidDisplay(authenticationSession.start())
        }
    }
}
