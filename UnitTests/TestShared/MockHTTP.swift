@testable import CorePayments
import Foundation

class MockHTTP: HTTP {

    var lastPOSTParameters: [String: Any]?
    var lastAPIRequest: (any APIRequest)?

    // Problem is you can't mock the return value of this func due to generics. I can't instantite the result type.
    override func performRequest<T: APIRequest>(_ request: T, withCaching: Bool = false) async throws -> (T.ResponseType) {
        lastAPIRequest = request
        if let body = request.body {
            lastPOSTParameters = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
        }
        return try await super.performRequest(request)
    }
}
