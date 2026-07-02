import XCTest
@testable import PayPalWebPayments

class PayPalURLConfig_Tests: XCTestCase {

    func testInit_setsAllUrls() {
        let config = PayPalURLConfig(
            returnAppUrl: "myapp://return",
            cancelAppUrl: "myapp://cancel",
            fallbackSchemeUrl: "myapp://fallback"
        )

        XCTAssertEqual(config.returnAppURL, "myapp://return")
        XCTAssertEqual(config.cancelAppURL, "myapp://cancel")
        XCTAssertEqual(config.fallbackSchemeURL, "myapp://fallback")
    }
}
