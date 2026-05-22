import Foundation
import AuthenticationServices

/// Protocol defining the interface for starting a web authentication session.
@_documentation(visibility: private)
public protocol WebAuthenticating {

    func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    )
}
