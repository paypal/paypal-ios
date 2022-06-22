import XCTest
@testable import PaymentsCore
@testable import Card

class GetOrderInfoRequest_Tests: XCTestCase {

    func testEncodingOrder_expectsValidOrderHTTPParams() throws {
        let mockOrderId = "mockOrderId"
        let mockSecret = "mockSecret"
        let mockClientId = "mockClientId"

        let getOrderInfoRequest = try XCTUnwrap(
            GetOrderInfoRequest(orderID: mockOrderId, clientID: mockClientId, secret: mockSecret)
        )

        let expectedPath = "v2/checkout/orders/\(mockOrderId)"
        let expectedMethod = HTTPMethod.get
        let encodedCredentials = "\(mockClientId):\(mockSecret)".data(using: .utf8)?.base64EncodedString() ?? ""
        let expectedHeaders: [HTTPHeader: String] = [
            .contentType: "application/json",
            .acceptLanguage: "en_US",
            .authorization: "Basic \(encodedCredentials)"
        ]

        XCTAssertNil(getOrderInfoRequest.body)
        XCTAssertEqual(getOrderInfoRequest.path, expectedPath)
        XCTAssertEqual(getOrderInfoRequest.method, expectedMethod)
        XCTAssertEqual(getOrderInfoRequest.headers, expectedHeaders)
    }
}
