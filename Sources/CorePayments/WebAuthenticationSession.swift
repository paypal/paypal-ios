import Foundation
import AuthenticationServices

public class WebAuthenticationSession: NSObject {

    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        let authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: PayPalCoreConstants.callbackURLScheme,
            completionHandler: sessionDidComplete
        )

        authenticationSession.presentationContextProvider = context

        DispatchQueue.main.async {
            sessionDidDisplay(authenticationSession.start())
        }
    }
}
