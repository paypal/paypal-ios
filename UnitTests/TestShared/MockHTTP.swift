@testable import PaymentsCore
import Foundation

// swiftlint:disable force_unwrapping
class MockHTTP: HTTP {
    
    var lastPOSTParameters: [String: Any]?
    var lastAPIRequest: (any APIRequest)?
    
    override func performRequest<T: APIRequest>(_ request: T) async throws -> (T.ResponseType) {
        lastAPIRequest = request
        lastPOSTParameters = try JSONSerialization.jsonObject(with: request.body!, options: []) as? [String: Any]
        return try await super.performRequest(request)
    }
}
