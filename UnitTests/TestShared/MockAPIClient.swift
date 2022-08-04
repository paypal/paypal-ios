import Foundation
@testable import PaymentsCore

class MockAPIClient: APIClient {

    var cannedClientID = "cannedClientID"

    override func getClientID() async throws -> String {
        return cannedClientID
    }
}
