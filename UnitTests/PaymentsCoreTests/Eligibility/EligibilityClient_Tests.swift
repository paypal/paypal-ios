import XCTest
@testable import CorePayments

class EligibilityClient_Tests: XCTestCase {
    
    let mockClientID = "mockClientId"
    let eligibilityRequest = EligibilityRequest(currencyCode: "SOME-CURRENCY", intent: .CAPTURE)
    
    var sut: EligibilityClient!
    var coreConfig: CoreConfig!
    var mockEligibilityAPI: MockEligibilityAPI!
    
    override func setUp() {
        super.setUp()
        coreConfig = CoreConfig(clientID: mockClientID, environment: .sandbox)
        mockEligibilityAPI = MockEligibilityAPI(coreConfig: coreConfig)
        sut = EligibilityClient(config: coreConfig, api: mockEligibilityAPI)
    }
    
    override func tearDown() {
        coreConfig = nil
        mockEligibilityAPI = nil
        sut = nil
        super.tearDown()
    }
    
    func testCheck_returnsSuccessResult() async throws {
        mockEligibilityAPI.stubResponse = .init(
            fundingEligibility: .init(
                venmo: .init(eligible: true),
                card: .init(eligible: true),
                paypal: .init(eligible: true),
                paylater: .init(eligible: false),
                credit: .init(eligible: false)
            )
        )
        
        do {
            let result = try await sut.check(eligibilityRequest)
            XCTAssertTrue(result.isVenmoEligible)
            XCTAssertTrue(result.isCardEligible)
            XCTAssertTrue(result.isPayPalEligible)
            XCTAssertFalse(result.isPayLaterEligible)
            XCTAssertFalse(result.isCreditEligible)
        } catch {
            XCTFail("Expected no error.")
        }
    }
    
    func testCheck_returnsError() async throws {
        mockEligibilityAPI.stubError = CoreSDKError(
            code: 123,
            domain: "client-error",
            errorDescription: "Some client error description."
        )
        
        do {
            _ = try await sut.check(eligibilityRequest)
            XCTFail("Expected error throw.")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.domain, "client-error")
            XCTAssertEqual(error.code, 123)
            XCTAssertEqual(error.localizedDescription, "Some client error description.")
        }
    }
}
