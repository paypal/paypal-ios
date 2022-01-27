import Foundation
import AuthenticationServices

public class WebAuthenticationSession: NSObject {

    public var authenticationSession: ASWebAuthenticationSession?
    public var presentationContextProvider: ASWebAuthenticationPresentationContextProviding?

    public func start(
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
