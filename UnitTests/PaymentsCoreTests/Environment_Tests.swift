import XCTest
@testable import CorePayments

class Environment_Tests: XCTestCase {

    func testEnvironment_sandboxURL_matchesExpectation() throws {
        let expectedUrlString = "https://api-m.sandbox.paypal.com"
        XCTAssertEqual(CoreEnvironment.sandbox.baseURL.absoluteString, expectedUrlString)
    }

    func testEnvironment_liveURL_matchesExpectation() throws {
        let expectedUrlString = "https://api-m.paypal.com"
        XCTAssertEqual(CoreEnvironment.live.baseURL.absoluteString, expectedUrlString)
    }
}
