import Foundation
import XCTest
@testable import PaymentsCore
@testable import Card

class ConfirmPaymentSourceRequest_Tests: XCTestCase {

    func testEncodingPaymentSource_withValidCardDictionary_expectsBody() throws {
        let mockOrderID = "mockOrderID"
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let cardRequest = CardRequest(orderID: mockOrderID, card: card)

        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(accessToken: "fake-token", cardRequest: cardRequest)
        )

        let paymentSourceBody = try XCTUnwrap(confirmPaymentSourceRequest.body)
        if let paymentSourceBodyString = String(data: paymentSourceBody, encoding: .utf8) {
            // swiftlint:disable line_length
            let expectedPaymentSourceBodyString = """
            {"application_context":{"return_url":"\(bundleID):\\/\\/card\\/success","cancel_url":"\(bundleID):\\/\\/card\\/cancel"},"payment_source":{"card":{"number":"4032036247327321","security_code":"222","billing_address":null,"name":null,"attributes":{"verification":{"method":"SCA_WHEN_REQUIRED"}},"expiry":"2024-11"}}}
            """
            // swiftlint:enable line_length

            XCTAssertEqual(paymentSourceBodyString, expectedPaymentSourceBodyString)
        }
    }

    func testEncodingPaymentSource_withValidCardDictionary_expectsValidHTTPParams() throws {
        let mockOrderId = "mockOrderId"
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )
        let cardRequest = CardRequest(orderID: mockOrderId, card: card)

        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(accessToken: "fake-token", cardRequest: cardRequest)
        )

        let expectedPath = "/v2/checkout/orders/\(mockOrderId)/confirm-payment-source"
        let expectedMethod = HTTPMethod.post
        let expectedHeaders: [HTTPHeader: String] = [
            .contentType: "application/json", .acceptLanguage: "en_US",
            .authorization: "Bearer fake-token"
        ]

        XCTAssertEqual(confirmPaymentSourceRequest.path, expectedPath)
        XCTAssertEqual(confirmPaymentSourceRequest.method, expectedMethod)
        XCTAssertEqual(confirmPaymentSourceRequest.headers, expectedHeaders)
    }
}
