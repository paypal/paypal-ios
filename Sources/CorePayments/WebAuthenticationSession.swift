import Foundation
@preconcurrency import AuthenticationServices

@_documentation(visibility: private)
public class WebAuthenticationSession: NSObject {

    public func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping @Sendable (Bool) -> Void,
        sessionDidCancel: (@Sendable () -> Void)? = nil,
        sessionDidComplete: @escaping @Sendable (URL?, Error?) -> Void
    ) {
        let authenticationSession = ASWebAuthenticationSession(
            url: url,
            callbackURLScheme: PayPalCoreConstants.callbackURLScheme
        ) { url, error in
            if let error = error as NSError?,
               error.domain == ASWebAuthenticationSessionError.errorDomain,
               error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                sessionDidCancel?()
            } else {
                sessionDidComplete(url, error)
            }
        }

        authenticationSession.presentationContextProvider = context

        DispatchQueue.main.async {
            sessionDidDisplay(authenticationSession.start())
        }
    }
}
