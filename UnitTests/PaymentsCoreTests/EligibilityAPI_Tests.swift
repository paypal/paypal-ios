import XCTest
@testable import PaymentsCore
@testable import TestShared

class EligibilityAPI_Tests: XCTestCase {

    let mockClientId = "mockClientId"
    let mockAccessToken = "mockAccessToken"
    // swiftlint:disable implicitly_unwrapped_optional
    var coreConfig: CoreConfig!
    var mockURLSession: MockURLSession!
    var graphQLClient: GraphQLClient!
    var eligibilityAPI: EligibilityAPI!
    // swiftlint:enable implicitly_unwrapped_optional
    override func setUp() {
        super.setUp()
        coreConfig = CoreConfig(accessToken: mockAccessToken, environment: .sandbox)
        mockURLSession = MockURLSession()
    }
    func testCheckEligibilityWithSuccessResponse() async throws {
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 200,
            httpVersion: "1",
            headerFields: ["Paypal-Debug-Id": "454532"]
        )
        mockURLSession.cannedJSONData = validFundingEligibilityResponse
        eligibilityAPI = EligibilityAPI(coreConfig: coreConfig)
        eligibilityAPI.graphQLClient = GraphQLClient(environment: .sandbox, urlSession: mockURLSession)
        let result = try await eligibilityAPI.checkEligibility()
        switch result {
        case .success(let eligibility):
            XCTAssertTrue(eligibility.isVenmoEligible)
            XCTAssertTrue(eligibility.isPaypalEligible)
            XCTAssertFalse(eligibility.isCreditCardEligible)
        case .failure(let error):
            XCTAssertNil(error)
        }
    }
    func testCheckEligibilityErrorResponse() async throws {
        mockURLSession.cannedURLResponse = HTTPURLResponse(
            // swiftlint:disable:next force_unwrapping
            url: URL(string: "www.fake.com")!,
            statusCode: 200,
            httpVersion: "1",
            headerFields: ["Paypal-Debug-Id": "454532"]
        )
        mockURLSession.cannedJSONData = notValidFundingEligibilityResponse
        eligibilityAPI = EligibilityAPI(coreConfig: coreConfig)
        eligibilityAPI.graphQLClient = GraphQLClient(environment: .sandbox, urlSession: mockURLSession)
        let result = try await eligibilityAPI.checkEligibility()
        switch result {
        case .success(let eligibility):
            XCTAssertNil(eligibility)
        case .failure(let failure):
            XCTAssertNotNil(failure)
        }
    }
    let notValidFundingEligibilityResponse = """
        {

        }
    """
    let validFundingEligibilityResponse = """
        {
            "data": {
            "fundingEligibility": {
                "venmo": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible",
                        "VENMO OPT-IN WITH ENABLE_FUNDING"
                    ]
                },
                "card": {
                    "eligible": false
                },
                "paypal": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible"
                    ]
                },
                "paylater": {
                    "eligible": true,
                    "reasons": [
                        "isPaymentMethodEnabled",
                        "isMSPEligible",
                        "isUnilateralPaymentSupported",
                        "isEnvEligible",
                        "isMerchantCountryEligible",
                        "isBuyerCountryEligible",
                        "isIntentEligible",
                        "isCommitEligible",
                        "isVaultEligible",
                        "isCurrencyEligible",
                        "isPaymentMethodDisabled",
                        "isDeviceEligible",
                        "CRC OFFERS SERV CALLED: Trmt_xo_xobuyernodeserv_call_crcoffersserv",
                        "CRC OFFERS SERV ELIGIBLE"
                    ]
                },
                "credit": {
                    "eligible": false,
                    "reasons": [
                        "INELIGIBLE DUE TO PAYLATER ELIGIBLE"
                    ]
                }
            }
        }
        }
        """
}
