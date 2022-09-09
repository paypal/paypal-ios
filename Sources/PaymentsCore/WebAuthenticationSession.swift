import Foundation
import AuthenticationServices

public class WebAuthenticationSession: NSObject {
    
    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        completion: @escaping (URL?, Error?) -> Void
    ) {
        let authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: Bundle.main.bundleIdentifier,
            completionHandler: completion
        )

        authenticationSession.prefersEphemeralWebBrowserSession = true
        authenticationSession.presentationContextProvider = context
        
        authenticationSession.start()
    }
}
