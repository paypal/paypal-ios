import Foundation
import AuthenticationServices
@testable import CorePayments

class MockWebAuthenticationSession: WebAuthenticationSession {

    var cannedResponseURL: URL?
    var cannedErrorResponse: Error?
    var cannedDidDisplayResult = true
    var lastLaunchedURL: URL?

    var onStart: (() -> Void)?
    var lastLaunchedCallbackURLScheme: String?

    override func start(
        url: URL,
        callbackURLScheme: String = PayPalCoreConstants.callbackURLScheme,
        context: ASWebAuthenticationPresentationContextProviding,
        sessionDidDisplay: @escaping (Bool) -> Void,
        sessionDidComplete: @escaping (URL?, Error?) -> Void
    ) {
        lastLaunchedURL = url
        lastLaunchedCallbackURLScheme = callbackURLScheme
        onStart?()
        
        sessionDidDisplay(cannedDidDisplayResult)
        sessionDidComplete(cannedResponseURL, cannedErrorResponse)
    }
}
