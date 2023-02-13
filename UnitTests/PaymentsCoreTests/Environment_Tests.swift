import XCTest
@testable import CorePayments

class Environment_Tests: XCTestCase {

    func testEnvironment_sandboxURL_matchesExpectation() throws {
        let expectedUrlString = "https://api.sandbox.paypal.com"
        XCTAssertEqual(Environment.sandbox.baseURL.absoluteString, expectedUrlString)
    }

    func testEnvironment_liveURL_matchesExpectation() throws {
        let expectedUrlString = "https://api.paypal.com"
        XCTAssertEqual(Environment.live.baseURL.absoluteString, expectedUrlString)
    }
}
