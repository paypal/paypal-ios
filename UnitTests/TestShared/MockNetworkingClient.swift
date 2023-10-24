import Foundation
@testable import CorePayments

class MockNetworkingClient: NetworkingClient {

    var stubHTTPResponse: HTTPResponse?
    var stubHTTPError: Error?
    
    var capturedRESTRequest: RESTRequest?
    var capturedGraphQLRequest: GraphQLRequest?
    
    override func fetch(request: RESTRequest) async throws -> HTTPResponse {
        capturedRESTRequest = request
        
        if let stubHTTPError {
            throw stubHTTPError
        }
        
        if let stubHTTPResponse {
            return stubHTTPResponse
        }
        
        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
    
    override func fetch(request: GraphQLRequest) async throws -> HTTPResponse {
        capturedGraphQLRequest = request
        
        if let stubHTTPError {
            throw stubHTTPError
        }
        
        if let stubHTTPResponse {
            return stubHTTPResponse
        }
        
        throw CoreSDKError(code: 0, domain: "", errorDescription: "Stubbed responses not implemented for this mock.")
    }
}
