@testable import CorePayments

class MockGraphQLClient: GraphQLClient {
    
    var mockSuccessResponse: GraphQLQueryResponse<UpdateSetupTokenResponse>?
    var mockErrorResponse: Error?
    
    override func callGraphQL<T, Q>(
        name: String,
        query: Q
    ) async throws -> GraphQLQueryResponse<T> where T: Decodable, T: Encodable, Q: GraphQLQuery {
        if let response = mockSuccessResponse as? GraphQLQueryResponse<T> {
            return response
        } else if let error = mockErrorResponse {
            throw error
        } else {
            fatalError("MockGraphQLClient - either mockSuccessResponse or mockErrorResponse must be set")
        }
    }
}
