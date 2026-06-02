import XCTest
@testable import VenmoPayments

class VenmoCheckoutRequest_Tests: XCTestCase {

    func testInit_setsOrderID() {
        let request = VenmoCheckoutRequest(orderID: "my-order-id")
        XCTAssertEqual(request.orderID, "my-order-id")
    }

    func testInit_defaultValues() {
        let request = VenmoCheckoutRequest(orderID: "order123")
        XCTAssertEqual(request.buyerCountry, "US")
        XCTAssertEqual(request.currency, "USD")
    }

    func testInit_customValues() {
        let request = VenmoCheckoutRequest(orderID: "order456", buyerCountry: "CA", currency: "CAD")
        XCTAssertEqual(request.orderID, "order456")
        XCTAssertEqual(request.buyerCountry, "CA")
        XCTAssertEqual(request.currency, "CAD")
    }
}
