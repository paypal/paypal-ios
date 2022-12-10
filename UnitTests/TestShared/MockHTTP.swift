@testable import PaymentsCore
import Foundation

class MockHTTP: HTTP {
    
    var lastPOSTParameters: [String: Any]?
    
    override func performRequest<T>(endpoint: T) async throws -> (T.ResponseType) where T: APIRequest {
        lastPOSTParameters = try JSONSerialization.jsonObject(with: endpoint.body!, options: []) as? [String: Any]
        return try await super.performRequest(endpoint: endpoint)
    }
}
