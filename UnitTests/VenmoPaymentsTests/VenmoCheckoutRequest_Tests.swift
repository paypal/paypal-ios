import XCTest
@testable import VenmoPayments

class VenmoCheckoutRequest_Tests: XCTestCase {

    func testInit_setsOrderID() {
        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        XCTAssertEqual(request.orderID, "ORDER-123")
    }

    func testInit_defaultValues() {
        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        XCTAssertEqual(request.currency, "USD")
    }

    func testInit_customValues() {
        let request = VenmoCheckoutRequest(orderID: "ORDER-456", currency: "CAD")
        XCTAssertEqual(request.orderID, "ORDER-456")
        XCTAssertEqual(request.currency, "CAD")
    }
}
