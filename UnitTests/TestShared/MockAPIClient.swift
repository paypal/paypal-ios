import Foundation
@testable import CorePayments

class MockAPIClient: APIClient {

    var cannedClientIDError: CoreSDKError?
    var cannedClientID = "cannedClientID"
    var cannedFetchResponse: Decodable?
    var cannedJSONResponse: String?
    var cannedFetchError: Error?
    
    override convenience init(coreConfig: CoreConfig) {
        self.init(urlSession: MockURLSession(), coreConfig: coreConfig)
    }
    
    override func fetch<T: APIRequest>(request: T) async throws -> (T.ResponseType) {
        if let cannedFetchError {
            throw cannedFetchError
        }
        // swiftlint:disable force_unwrapping
        let cannedData = cannedJSONResponse!.data(using: String.Encoding.utf8)!
        return try APIClientDecoder().decode(T.self, from: cannedData)
    }

    override func getClientID() async throws -> String {
        if let cannedClientIDError {
            throw cannedClientIDError
        }
        return cannedClientID
    }
}
