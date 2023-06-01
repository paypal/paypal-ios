import Foundation
@testable import CorePayments

class MockAPIClient: APIClient {

    var cannedClientIDError: CoreSDKError?
    var cannedClientID = "cannedClientID"
    var cannedJSONResponse: String?
    var cannedFetchError: Error?
    
    var postedAnalyticsEvents: [String] = []
        
    override func fetch<T: APIRequest>(request: T) async throws -> (T.ResponseType) {
        if let cannedFetchError {
            throw cannedFetchError
        }
        let cannedData = cannedJSONResponse!.data(using: String.Encoding.utf8)!
        return try HTTPResponseParser().parse(
            HTTPResponse(status: 200, body: cannedData),
            as: T.ResponseType.self
        )
    }
}
