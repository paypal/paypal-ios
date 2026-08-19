import XCTest
@testable import PayPalPayments

class PayPalURLConfig_Tests: XCTestCase {

    func testInit_setsAllUrls() {
        let config = PayPalURLConfig(
            returnAppURL: URL(string: "myapp://return")!,
            cancelAppURL: URL(string: "myapp://cancel")!,
            fallbackSchemeURL: URL(string: "myapp://fallback")!
        )

        XCTAssertEqual(config.returnAppURL, URL(string: "myapp://return"))
        XCTAssertEqual(config.cancelAppURL, URL(string: "myapp://cancel"))
        XCTAssertEqual(config.fallbackSchemeURL, URL(string: "myapp://fallback"))
    }
}
