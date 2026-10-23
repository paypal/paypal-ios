import XCTest
@testable import CorePayments
@testable import VenmoPayments

class CoreEnvironment_Venmo_Tests: XCTestCase {

    func testVenmoEnvironment_sandbox_returnsCorrectCheckoutURL() {
        XCTAssertEqual(
            CoreEnvironment.sandbox.venmoCheckoutBaseURL.absoluteString,
            "https://www.sandbox.paypal.com/smart/checkout/venmo"
        )
    }

    func testVenmoEnvironment_live_returnsCorrectCheckoutURL() {
        XCTAssertEqual(
            CoreEnvironment.live.venmoCheckoutBaseURL.absoluteString,
            "https://www.paypal.com/smart/checkout/venmo"
        )
    }

    func testVenmoEnvironment_sandbox_returnsCorrectEnvironmentString() {
        XCTAssertEqual(CoreEnvironment.sandbox.venmoEnvironmentString, "sandbox")
    }

    func testVenmoEnvironment_live_returnsCorrectEnvironmentString() {
        XCTAssertEqual(CoreEnvironment.live.venmoEnvironmentString, "production")
    }

    func testVenmoEnvironment_custom_returnsStageEnvironmentString() {
        XCTAssertEqual(
            CoreEnvironment.custom(baseURL: "https://custom.example.com", graphQLURL: "https://custom.example.com/graphql")
                .venmoEnvironmentString,
            "stage"
        )
    }
}
