import XCTest
@testable import PayPalWebPayments

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

    // MARK: - isReturnToAppConfigMissing

    func testIsReturnToAppConfigMissing_whenBothUsable_returnsFalse() {
        let config = PayPalURLConfig(
            returnAppURL: URL(string: "https://example.com/return")!,
            cancelAppURL: URL(string: "https://example.com/cancel")!,
            fallbackSchemeURL: URL(string: "myapp://paypal/return")!
        )

        XCTAssertFalse(config.isReturnToAppConfigMissing)
    }

    func testIsReturnToAppConfigMissing_whenOnlyReturnAppURLUsable_fallbackNil_returnsFalse() {
        let config = PayPalURLConfig(
            returnAppURL: URL(string: "https://example.com/return")!,
            cancelAppURL: URL(string: "https://example.com/cancel")!,
            fallbackSchemeURL: nil
        )

        XCTAssertFalse(config.isReturnToAppConfigMissing)
    }

    func testIsReturnToAppConfigMissing_whenOnlyFallbackUsable_returnAppURLSchemeOnly_returnsFalse() {
        let config = PayPalURLConfig(
            returnAppURL: URL(string: "myapp://")!,
            cancelAppURL: URL(string: "https://example.com/cancel")!,
            fallbackSchemeURL: URL(string: "myapp://paypal/return")!
        )

        XCTAssertFalse(config.isReturnToAppConfigMissing)
    }

    func testIsReturnToAppConfigMissing_whenReturnSchemeOnly_fallbackNil_returnsTrue() {
        let config = PayPalURLConfig(
            returnAppURL: URL(string: "myapp://")!,
            cancelAppURL: URL(string: "https://example.com/cancel")!,
            fallbackSchemeURL: nil
        )

        XCTAssertTrue(config.isReturnToAppConfigMissing)
    }

    func testIsReturnToAppConfigMissing_whenBothSchemeOnly_returnsTrue() {
        let config = PayPalURLConfig(
            returnAppURL: URL(string: "https://")!,
            cancelAppURL: URL(string: "https://example.com/cancel")!,
            fallbackSchemeURL: URL(string: "myapp://")!
        )

        XCTAssertTrue(config.isReturnToAppConfigMissing)
    }
}
