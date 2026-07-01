import XCTest
@testable import PayPalWebPayments

class PayPalURLConfig_Tests: XCTestCase {

    func testInit_setsAllUrls() {
        let config = PayPalURLConfig(
            returnAppUrl: "myapp://return",
            cancelAppUrl: "myapp://cancel",
            fallbackSchemeUrl: "myapp://fallback"
        )

        XCTAssertEqual(config.returnAppUrl, "myapp://return")
        XCTAssertEqual(config.cancelAppUrl, "myapp://cancel")
        XCTAssertEqual(config.fallbackSchemeUrl, "myapp://fallback")
    }
}
