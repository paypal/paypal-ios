import Foundation
import AuthenticationServices
@testable import CorePayments

class MockWebAuthenticationSession: WebAuthenticating {

    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    var cannedDidDisplayResult = true
    var lastLaunchedURL: URL?
    private(set) var startCallCount = 0

    var onStart: (() -> Void)?

    func start(
        url: URL,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        startCallCount += 1
        lastLaunchedURL = url
        onStart?()

        sessionDidDisplay(cannedDidDisplayResult)
        sessionDidComplete(cannedResponseURL, cannedErrorResponse)
    }
}
