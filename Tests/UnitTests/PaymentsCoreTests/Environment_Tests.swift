import XCTest
@testable import PaymentsCore

class Environment_Tests: XCTestCase {
    func testEnvironment_sandboxURL_matchesExpectation() throws {
        let expectedUrlString = "https://api.sandbox.paypal.com"
        XCTAssertEqual(Environment.sandbox.baseURL.absoluteString, expectedUrlString)
    }

    func testEnvironment_productionURL_matchesExpectation() throws {
        let expectedUrlString = "https://api.paypal.com"
        XCTAssertEqual(Environment.production.baseURL.absoluteString, expectedUrlString)
    }
}
