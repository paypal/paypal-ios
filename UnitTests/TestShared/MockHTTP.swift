@testable import CorePayments
import Foundation

class MockHTTP: HTTP {

    var lastPOSTParameters: [String: Any]?
    var lastAPIRequest: (any APIRequest)?

    override func performRequest<T: APIRequest>(_ request: T, withCaching: Bool = false) async throws -> (T.ResponseType) {
        lastAPIRequest = request
        if let body = request.body {
            lastPOSTParameters = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
        }
        return try await super.performRequest(request)
    }
}
