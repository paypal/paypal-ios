import Foundation
import XCTest
@testable import CorePayments
@testable import CardPayments
@testable import TestShared

class ConfirmPaymentSourceRequest_Tests: XCTestCase {

    func testEncodingPaymentSource_withValidCardDictionary_expectsBody() throws {
        let mockOrderID = "mockOrderID"
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )
        let cardRequest = CardRequest(orderID: mockOrderID, card: card)

        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(accessToken: "fake-token", cardRequest: cardRequest)
        )

        let paymentSourceBody = try XCTUnwrap(confirmPaymentSourceRequest.body)
        if let paymentSourceBodyString = String(data: paymentSourceBody, encoding: .utf8) {
            let expectedPaymentSourceBodyString = """
                {
                    "application_context": {
                        "return_url": "sdk.ios.paypal:\\/\\/card\\/success",
                        "cancel_url": "sdk.ios.paypal:\\/\\/card\\/cancel"
                    },
                    "payment_source": {
                        "card": {
                            "number": "4032036247327321",
                            "security_code": "222",
                            "billing_address": null,
                            "name": null,
                            "attributes": {
                                "verification": {
                                    "method": "SCA_WHEN_REQUIRED"
                                }
                        },
                            "expiry": "2024-11"
                        }
                    }
                }
                """.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")
            
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

    func testEncodingFailure_throws_EncodingError() throws {
        let mockOrderID = "mockOrderID"
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )
        let cardRequest = CardRequest(orderID: mockOrderID, card: card)
        
        let failingEncoder = FailingJSONEncoder()
        
        XCTAssertThrowsError(
            try ConfirmPaymentSourceRequest(
            accessToken: "fake token",
            cardRequest: cardRequest,
            encoder: failingEncoder)
        ) { error in
            guard let coreSDKError = error as? CoreSDKError else {
                XCTFail("Thrown error should be a CoreSDKError")
                return
            }
            XCTAssertEqual(coreSDKError.code, CardClientError.encodingError.code)
        }
    }
}
