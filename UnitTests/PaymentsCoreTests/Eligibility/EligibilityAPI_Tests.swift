import XCTest
@testable import CorePayments
@testable import TestShared

class EligibilityAPI_Tests: XCTestCase {
    
    let mockClientID = "mockClientId"
    let mockURLSession = MockURLSession()
    let eligibilityRequest = EligibilityRequest()
    
    var sut: EligibilityAPI!
    var coreConfig: CoreConfig!
    var mockNetworkingClient: MockNetworkingClient!
    
    override func setUp() {
        super.setUp()
        coreConfig = CoreConfig(clientID: mockClientID, environment: .sandbox)
        let mockHTTP = MockHTTP(coreConfig: coreConfig)
        mockNetworkingClient = MockNetworkingClient(http: mockHTTP)
        sut = EligibilityAPI(coreConfig: coreConfig, networkingClient: mockNetworkingClient)
    }
    
    override func tearDown() {
        coreConfig = nil
        mockNetworkingClient = nil
        sut = nil
        super.tearDown()
    }
    
    func testCheckSuccess() async throws {
        let rawQuery = """
        query getEligibility(
            $clientId: String!,
            $intent: FundingEligibilityIntent!,
            $currency: SupportedCountryCurrencies!,
            $enableFunding: [SupportedPaymentMethodsType]
        ){
            fundingEligibility(
                clientId: $clientId,
                intent: $intent
                currency: $currency,
                enableFunding: $enableFunding){
                venmo{
                    eligible
                    reasons
                }
                card{
                    eligible
                }
                paypal{
                    eligible
                    reasons
                }
                paylater{
                    eligible
                    reasons
                }
                credit{
                    eligible
                    reasons
                }
            }
        }
        """
        
        _ = try? await sut.check(eligibilityRequest)
        
        XCTAssertEqual(mockNetworkingClient.capturedGraphQLRequest?.query, rawQuery)
        XCTAssertNil(mockNetworkingClient.capturedGraphQLRequest?.queryNameForURL)
        
        let variables = mockNetworkingClient.capturedGraphQLRequest?.variables as! EligibilityVariables
        XCTAssertEqual(variables.clientID, mockClientID)
        XCTAssertEqual(variables.eligibilityRequest.currency.rawValue, "USD")
        XCTAssertEqual(variables.eligibilityRequest.intent.rawValue, "CAPTURE")
    }
    
    func testUpdateSetupToken_whenNetworkingClientError_bubblesError() async {
        mockNetworkingClient.stubHTTPError = CoreSDKError(code: 123, domain: "api-client-error", errorDescription: "error-desc")
        
        do {
            _ = try await sut.check(eligibilityRequest)
            XCTFail("Expected error throw.")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.domain, "api-client-error")
            XCTAssertEqual(error.code, 123)
            XCTAssertEqual(error.localizedDescription, "error-desc")
        }
    }
    
    func testUpdateSetupToken_whenSuccess_returnsParsedUpdateSetupTokenResponse() async throws {
        let successsResponseJSON = """
        {
            "data": {
                "fundingEligibility": {
                    "venmo": {
                        "eligible": true,
                        "reasons": []
                    },
                    "card": {
                        "eligible": true
                    },
                    "paypal": {
                        "eligible": true,
                        "reasons": []
                    },
                    "paylater": {
                        "eligible": true,
                        "reasons": []
                    },
                    "credit": {
                        "eligible": false,
                        "reasons": ["INELIGIBLE DUE TO PAYLATER ELIGIBLE"]
                    }
                }
            }
        }
        """
        
        let data = successsResponseJSON.data(using: .utf8)
        let stubbedHTTPResponse = HTTPResponse(status: 200, body: data)
        mockNetworkingClient.stubHTTPResponse = stubbedHTTPResponse
        
        let response = try await sut.check(eligibilityRequest)
        XCTAssertTrue(response.isVenmoEligible)
        XCTAssertTrue(response.isCardEligible)
        XCTAssertTrue(response.isPayPalEligible)
        XCTAssertTrue(response.isPayLaterEligible)
        XCTAssertFalse(response.isCreditEligible)
    }
}
