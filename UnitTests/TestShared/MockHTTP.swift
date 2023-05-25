@testable import CorePayments
import Foundation

class MockHTTP: HTTP {

    var lastPOSTParameters: [String: Any]? = nil
    var lastAPIRequest: (any APIRequest)?
    
    var stubHTTPResponse: HTTPResponse?
    var stubHTTPError: Error?
    
    init(coreConfig: CoreConfig = CoreConfig(accessToken: "fake-access-token", environment: .sandbox)) {
        super.init(coreConfig: coreConfig)
    }

    // Problem is you can't mock the return value of this func due to generics. I can't instantite the result type.
    override func performRequest<T: APIRequest>(_ request: T, withCaching: Bool = false) async throws -> (T.ResponseType) {
        lastAPIRequest = request
        if let body = request.body {
            lastPOSTParameters = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
        }
        return try await super.performRequest(request)
    }
    
    override func performRequest(_ request: any APIRequest) async throws -> HTTPResponse {
        lastAPIRequest = request
        
        // Is there a better way to do this? Returning a codable type maybe?
        if let body = request.body {
            lastPOSTParameters = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
        }
        
        if let stubHTTPError {
            throw stubHTTPError
        } else {
            return stubHTTPResponse ?? HTTPResponse(status: 200, body: nil)
        }
    }
}
