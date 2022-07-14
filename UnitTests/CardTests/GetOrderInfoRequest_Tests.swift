import XCTest
@testable import PaymentsCore
@testable import Card

class GetOrderInfoRequest_Tests: XCTestCase {

    func testEncodingOrder_expectsValidOrderHTTPParams() throws {
        let mockOrderId = "mockOrderId"
        let mockAccessToken = "mockAccessToken"

        let getOrderInfoRequest = try XCTUnwrap(
            GetOrderInfoRequest(orderID: mockOrderId, token: mockAccessToken)
        )

        let expectedPath = "v2/checkout/orders/\(mockOrderId)"
        let expectedMethod = HTTPMethod.get
        let expectedHeaders: [HTTPHeader: String] = [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Bearer \(mockAccessToken)"
        ]

        XCTAssertNil(getOrderInfoRequest.body)
        XCTAssertEqual(getOrderInfoRequest.path, expectedPath)
        XCTAssertEqual(getOrderInfoRequest.method, expectedMethod)
        XCTAssertEqual(getOrderInfoRequest.headers, expectedHeaders)
    }
}
