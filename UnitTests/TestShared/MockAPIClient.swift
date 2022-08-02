import Foundation
@testable import PaymentsCore

class MockAPIClient: APIClient {

    var cannedClientID = "cannedClientID"

    override func getClientId() async throws -> String {
        return cannedClientID
    }
}
