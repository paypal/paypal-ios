import Foundation
import AuthenticationServices

class WebAuthenticationSession: NSObject {

    var authenticationSession: ASWebAuthenticationSession?
    var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

    func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        self.authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: Bundle.main.bundleIdentifier,
            completionHandler: completion
        )

        if #available(iOS 13.0, *) {
            authenticationSession?.presentationContextProvider = context
        }

        authenticationSession?.start()
    }
}
