import Foundation
@testable import CorePayments

class MockAPIClient: APIClient {

    var cannedClientIDError: CoreSDKError?
    var cannedClientID = "cannedClientID"
    var cannedFetchResponse: Decodable?
    var cannedJSONResponse: String?
    var cannedFetchError: Error?
    
    var postedAnalyticsEvents: [String] = []
    
    override convenience init(coreConfig: CoreConfig) {
        self.init(http: HTTP(urlSession: MockURLSession(), coreConfig: coreConfig))
    }
    
    override func fetch<T: APIRequest>(request: T) async throws -> (T.ResponseType) {
        if let cannedFetchError {
            throw cannedFetchError
        }
        let cannedData = cannedJSONResponse!.data(using: String.Encoding.utf8)!
        return try APIClientDecoder().decode(T.self, from: cannedData)
    }
}
