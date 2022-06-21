import XCTest
@testable import PaymentsCore
@testable import TestShared

class GraphQLClient_Tests: XCTestCase {

    // MARK: - Helper Properties

    // swiftlint:disable:next force_unwrapping
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let config = CoreConfig(clientID: "", environment: .sandbox)
    let fakeRequest = FakeRequest()

    // swiftlint:disable implicitly_unwrapped_optional
    var mockURLSession: MockURLSession!
    var graphQLClient: GraphQLClient!
    var graphQLQuery: GraphQLQuery!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()

        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil

        graphQLClient = GraphQLClient(environment: .sandbox, urlSession: mockURLSession)

        let fundingEligibilityQuery = FundingEligibilityQuery(
            clientId: config.clientID,
            fundingEligibilityIntent: FundingEligibilityIntent.CAPTURE,
            currencyCode: SupportedCountryCurrencyType.USD,
            enableFunding: [SupportedPaymentMethodsType.VENMO]
        )

        graphQLQuery = fundingEligibilityQuery
    }

    // MARK: - fetch() tests

    func testGraphQLClient_verifyEmptyResponse() async throws {
        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = graphQLQueryResponseWithoutData

        do {
            let response: GraphQLQueryResponse<FundingEligibilityResponse> = try await graphQLClient.executeQuery(query: graphQLQuery)
            XCTAssertTrue(response.data == nil)
        } catch {
            print(error.localizedDescription)
            XCTFail("Expect success response")
        }
    }

    let graphQLQueryResponseWithData = """
          { "data":
            {
                
            }
          }
        """
    
    let graphQLQueryResponseWithoutData = """
      {
        
      }
    """
}
