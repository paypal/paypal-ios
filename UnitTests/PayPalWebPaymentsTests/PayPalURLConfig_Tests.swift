import XCTest
@testable import PayPalWebPayments

class PayPalURLConfig_Tests: XCTestCase {

    func testInit_setsReturnAndCancelUrls() {
        let config = PayPalURLConfig(returnAppUrl: "myapp://return", cancelAppUrl: "myapp://cancel")

        XCTAssertEqual(config.returnAppUrl, "myapp://return")
        XCTAssertEqual(config.cancelAppUrl, "myapp://cancel")
    }

    func testInit_fallbackSchemeUrlDefaultsToNil() {
        let config = PayPalURLConfig(returnAppUrl: "myapp://return", cancelAppUrl: "myapp://cancel")

        XCTAssertNil(config.fallbackSchemeUrl)
    }

    func testInit_withFallbackSchemeUrl_setsFallbackSchemeUrl() {
        let config = PayPalURLConfig(
            returnAppUrl: "myapp://return",
            cancelAppUrl: "myapp://cancel",
            fallbackSchemeUrl: "myapp://fallback"
        )

        XCTAssertEqual(config.fallbackSchemeUrl, "myapp://fallback")
    }
}
