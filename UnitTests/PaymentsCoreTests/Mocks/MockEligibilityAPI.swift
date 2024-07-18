import Foundation
@testable import CorePayments

class MockEligibilityAPI: EligibilityAPI {
    
    var stubResponse: EligibilityResponse?
    var stubError: Error?
    
    var capturedRequest: EligibilityRequest?
    
    override func check(_ eligibilityRequest: EligibilityRequest) async throws -> EligibilityResponse {
        capturedRequest = eligibilityRequest
        
        if let stubError {
            throw stubError
        }
        
        if let stubResponse {
            return stubResponse
        }
        
        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
