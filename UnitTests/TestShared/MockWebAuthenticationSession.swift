import Foundation
import AuthenticationServices
@testable import CorePayments

class MockWebAuthenticationSession: WebAuthenticationSession {

    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    var cannedDidDisplayResult = true

    override func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        sessionDidDisplay(cannedDidDisplayResult)
        sessionDidComplete(cannedResponseURL, cannedErrorResponse)
    }
}
