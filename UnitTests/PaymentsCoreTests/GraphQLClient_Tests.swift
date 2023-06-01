import XCTest
@testable import CorePayments
@testable import TestShared

class GraphQLClient_Tests: XCTestCase {

    let mockClientID = "mockClientId"
    
    // MARK: - Helper Properties
    
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let fakeRequest = FakeRequest()
    var config: CoreConfig!
    var mockURLSession: MockURLSession!
    var graphQLClient: GraphQLClient!
    var graphQLQuery: GraphQLQuery!

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: mockClientID, environment: .sandbox)
        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil

        graphQLClient = GraphQLClient(environment: .sandbox, urlSession: mockURLSession)

        let fundingEligibilityQuery = FundingEligibilityQuery(
            clientID: mockClientID,
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


        mockURLSession.cannedURLResponse = HTTPURLResponse(
            url: URL(string: "www.fake.com")!,
            statusCode: 200,
            httpVersion: "1",
            headerFields: ["Paypal-Debug-Id": "454532"]
        )

        do {
            let response: GraphQLQueryResponse<FundingEligibilityResponse> = try await graphQLClient.executeQuery(query: graphQLQuery)
            XCTAssertTrue(response.data == nil)
        } catch {
            print(error.localizedDescription)
            XCTFail("Expected success response")
        }
    }

    func testGraphQLClient_verifyNonEmptyResponse() async throws {
        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = graphQLQueryResponseWithData


        mockURLSession.cannedURLResponse = HTTPURLResponse(
            url: URL(string: "www.fake.com")!,
            statusCode: 200,
            httpVersion: "1",
            headerFields: ["Paypal-Debug-Id": "454532"]
        )

        do {
            let response: GraphQLQueryResponse<FundingEligibilityResponse> = try await graphQLClient.executeQuery(query: graphQLQuery)
            XCTAssertTrue(response.data != nil)
        } catch {
            XCTAssertTrue(!error.localizedDescription.isEmpty)
        }
    }

    let graphQLQueryResponseWithData = """
        {
            "data": {}
        }
    """

    let graphQLQueryResponseWithoutData = """
        {

        }
    """
}
