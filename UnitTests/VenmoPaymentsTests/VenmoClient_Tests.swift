import XCTest
@testable import CorePayments
@testable import VenmoPayments
@testable import TestShared

class VenmoClient_Tests: XCTestCase {

    var config: CoreConfig!
    var venmoClient: VenmoClient!

    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "testClientID", environment: .sandbox)
        venmoClient = VenmoClient(config: config)
    }

    func testStart_throwsUnimplemented() async {
        let request = VenmoCheckoutRequest(orderID: "test-order-id")

        do {
            _ = try await venmoClient.start(request)
            XCTFail("Expected start() to throw VenmoError.unimplemented")
        } catch {
            guard let sdkError = error as? CoreSDKError else {
                XCTFail("Expected CoreSDKError but got \(type(of: error))")
                return
            }
            XCTAssertEqual(sdkError.code, VenmoError.unimplemented.code)
            XCTAssertEqual(sdkError.domain, VenmoError.unimplemented.domain)
            XCTAssertEqual(sdkError.errorDescription, VenmoError.unimplemented.errorDescription)
        }
    }

    func testHandleReturnURL_doesNotCrash() {
        let url = URL(string: "https://example.com/return?token=abc&PayerID=xyz")!
        venmoClient.handleReturnURL(url)
        // No crash = pass. handleReturnURL is a no-op in the scaffold.
    }
}
