import XCTest
@testable import CorePayments
@testable import VenmoPayments

class CoreEnvironment_Venmo_Tests: XCTestCase {

    func testVenmoBaseURL_sandbox_usesExtLiveHost() {
        XCTAssertEqual(CoreEnvironment.sandbox.venmoBaseURL.absoluteString, "https://account.ext.live.venmo.com")
    }

    func testVenmoBaseURL_live_usesAccountHost() {
        XCTAssertEqual(CoreEnvironment.live.venmoBaseURL.absoluteString, "https://account.venmo.com")
    }
}
