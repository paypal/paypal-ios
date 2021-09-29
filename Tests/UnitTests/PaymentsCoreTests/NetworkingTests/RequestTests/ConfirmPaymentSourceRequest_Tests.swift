import Foundation
import XCTest
@testable import PaymentsCore
@testable import Card

final class ConfirmPaymentSourceRequest_Tests: XCTestCase {

    func testEncodingPaymentSource_withValidCardDictionary_expectsValidPaymentSourceBody() throws {
        let card = Card(
            number: "4032036247327321",
            expirationDate: ExpirationDate(month: 11, year: 2024),
            securityCode: "222"
        )
        let cardDictionary = ["card": card]

        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(
                paymentSource: cardDictionary,
                orderID: "",
                clientID: ""
            )
        )

        let paymentSourceBody = try XCTUnwrap(confirmPaymentSourceRequest.body)
        let paymentSourceBodyString = String(data: paymentSourceBody, encoding: .utf8)

        let expectedPaymentSourceBodyString = """
        {"payment_source":{"card":{"number":"4032036247327321","security_code":"222","expiry":"2024-11"}}}
        """

        XCTAssertEqual(paymentSourceBodyString, expectedPaymentSourceBodyString)
    }
}
