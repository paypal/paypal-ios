import XCTest
@testable import VenmoPayments

class VenmoCheckoutRequest_Tests: XCTestCase {

    func testInit_setsOrderID() {
        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        XCTAssertEqual(request.orderID, "ORDER-123")
    }

    func testInit_defaultValues() {
        let request = VenmoCheckoutRequest(orderID: "ORDER-123")
        XCTAssertEqual(request.buyerCountry, "US")
        XCTAssertEqual(request.currency, "USD")
        XCTAssertNil(request.returnURL)
    }

    func testInit_withReturnURL_setsReturnURL() {
        let request = VenmoCheckoutRequest(orderID: "ORDER-123", returnURL: "https://example.com/success")
        XCTAssertEqual(request.returnURL, "https://example.com/success")
    }

    func testInit_customValues() {
        let request = VenmoCheckoutRequest(orderID: "ORDER-456", buyerCountry: "CA", currency: "CAD")
        XCTAssertEqual(request.orderID, "ORDER-456")
        XCTAssertEqual(request.buyerCountry, "CA")
        XCTAssertEqual(request.currency, "CAD")
    }
}
