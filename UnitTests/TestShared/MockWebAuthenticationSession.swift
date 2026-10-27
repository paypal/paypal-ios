import Foundation
import AuthenticationServices
@testable import CorePayments

class MockWebAuthenticationSession: WebAuthenticationSession {

    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    var cannedDidDisplayResult = true
    var lastLaunchedURL: URL?

    var onStart: (() -> Void)?

    override func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidCancel: (() -> Void)? = nil,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        lastLaunchedURL = url
        onStart?()

        sessionDidDisplay(cannedDidDisplayResult)

        if let error = cannedErrorResponse as? NSError,
           error.domain == ASWebAuthenticationSessionError.errorDomain,
           error.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
            sessionDidCancel?()
        } else {
            sessionDidComplete(cannedResponseURL, cannedErrorResponse)
        }
    }
}
