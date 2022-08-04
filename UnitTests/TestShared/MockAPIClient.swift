import Foundation
@testable import PaymentsCore

class MockAPIClient: APIClient {

    var error: CoreSDKError?
    var cannedClientID = "cannedClientID"

    override func getClientID() async throws -> String {
        if let error = error {
            throw error
        }
        return cannedClientID
    }
}
