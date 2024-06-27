import Foundation
import AuthenticationServices
@testable import CorePayments

class MockWebAuthenticationSession: WebAuthenticationSession {

    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    var cannedDidDisplayResult = true
    var lastLaunchedURL: URL?

    override func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        lastLaunchedURL = url
        sessionDidDisplay(cannedDidDisplayResult)
        sessionDidComplete(cannedResponseURL, cannedErrorResponse)
    }
}
