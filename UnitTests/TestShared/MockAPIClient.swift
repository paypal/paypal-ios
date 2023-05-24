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
    
    override func fetch<T: Decodable>(endpoint: Endpoint, responseModel: T.Type) async throws -> T {
        if let cannedFetchError {
            throw cannedFetchError
        } else {
            let cannedData = cannedJSONResponse!.data(using: String.Encoding.utf8)!
            return try APIClientDecoder().decode(T.self, from: cannedData)
        }
    }

    override func fetchCachedOrRemoteClientID() async throws -> String {
        if let cannedClientIDError {
            throw cannedClientIDError
        }
        return cannedClientID
    }
}
