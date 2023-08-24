@testable import CorePayments
import Foundation

class MockHTTP: HTTP {
        
    var stubHTTPResponse: HTTPResponse?
    var stubHTTPError: Error?
    
    var capturedHTTPRequest: HTTPRequest?
    
    override func performRequest(_ httpRequest: HTTPRequest) async throws -> HTTPResponse {
        capturedHTTPRequest = httpRequest
        
        if let stubHTTPError {
            throw stubHTTPError
        }
        
        if let stubHTTPResponse {
            return stubHTTPResponse
        }
        
        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
