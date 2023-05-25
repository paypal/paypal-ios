@testable import CorePayments
import Foundation

class MockHTTP: HTTP {

    var lastPOSTParameters: [String: Any]?
    var lastAPIRequest: (any APIRequest)?
    
    var stubHTTPResponse: HTTPResponse?
    var stubHTTPError: Error?
    
    init(coreConfig: CoreConfig = CoreConfig(accessToken: "fake-access-token", environment: .sandbox)) {
        super.init(coreConfig: coreConfig)
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
