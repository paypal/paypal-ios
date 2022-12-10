@testable import PaymentsCore
import Foundation

// swiftlint:disable force_unwrapping
class MockHTTP: HTTP {
    
    var lastPOSTParameters: [String: Any]?
    var lastAPIRequest: (any APIRequest)?
    
    override func performRequest<T>(endpoint: T) async throws -> (T.ResponseType) where T: APIRequest {
        lastAPIRequest = endpoint
        lastPOSTParameters = try JSONSerialization.jsonObject(with: endpoint.body!, options: []) as? [String: Any]
        return try await super.performRequest(endpoint: endpoint)
    }
}
