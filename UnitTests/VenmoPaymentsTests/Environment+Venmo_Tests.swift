import XCTest
@testable import CorePayments
@testable import VenmoPayments

class Environment_Venmo_Tests: XCTestCase {

    func testVenmoEnvironment_sandbox_returnsCorrectCheckoutURL() {
        XCTAssertEqual(
            Environment.sandbox.venmoCheckoutBaseURL.absoluteString,
            "https://www.sandbox.paypal.com/smart/checkout/venmo"
        )
    }

    func testVenmoEnvironment_live_returnsCorrectCheckoutURL() {
        XCTAssertEqual(
            Environment.live.venmoCheckoutBaseURL.absoluteString,
            "https://www.paypal.com/smart/checkout/venmo"
        )
    }

    func testVenmoEnvironment_sandbox_returnsCorrectEnvironmentString() {
        XCTAssertEqual(Environment.sandbox.venmoEnvironmentString, "sandbox")
    }

    func testVenmoEnvironment_live_returnsCorrectEnvironmentString() {
        XCTAssertEqual(Environment.live.venmoEnvironmentString, "production")
    }

    func testVenmoEnvironment_custom_returnsStageEnvironmentString() {
        XCTAssertEqual(
            Environment.custom(baseURL: "https://custom.example.com", graphQLURL: "https://custom.example.com/graphql")
                .venmoEnvironmentString,
            "stage"
        )
    }
}
