import Foundation
import XCTest
@testable import CorePayments
@testable import CardPayments
@testable import TestShared

class ConfirmPaymentSourceRequest_Tests: XCTestCase {

    func testEncodingPaymentSource_withValidCard() throws {
        let mockOrderID = "mockOrderID"
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )
        let cardRequest = CardRequest(orderID: mockOrderID, card: card)
        
        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(clientID: "fake-token", cardRequest: cardRequest)
        )
        
        let paymentSourceBody = try XCTUnwrap(confirmPaymentSourceRequest.body)
        
        let expectedPaymentSourceDict: [String: Any?] = [
            "application_context": [
                "return_url": "sdk.ios.paypal://card/success",
                "cancel_url": "sdk.ios.paypal://card/cancel"
            ],
            "payment_source": [
                "card": [
                    "number": "4032036247327321",
                    "security_code": "222",
                    "billing_address": nil,
                    "name": nil,
                    "attributes": [
                        "verification": [
                            "method": "SCA_WHEN_REQUIRED"
                        ]
                    ],
                    "expiry": "2024-11"
                ] as [String: Any?]
            ]
        ]
        let paymentSourceDict = try JSONSerialization.jsonObject(with: paymentSourceBody, options: []) as! [String: Any]
        XCTAssertEqual(paymentSourceDict as NSDictionary, expectedPaymentSourceDict as NSDictionary)
    }
    
    func testEncodingPaymentSource_withValidCard_andVaultWithPurchase() throws {
        let mockOrderID = "mockOrderID"
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )

        let vault = Vault(customerID: "testCustomer1")
        let cardRequest = CardRequest(orderID: mockOrderID, card: card, vault: vault)

        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(clientID: "fake-token", cardRequest: cardRequest)
        )

        let paymentSourceBody = try XCTUnwrap(confirmPaymentSourceRequest.body)
        let expectedPaymentSourceDict: [String: Any?] = [
            "application_context": [
                "return_url": "sdk.ios.paypal://card/success",
                "cancel_url": "sdk.ios.paypal://card/cancel"
            ],
            "payment_source": [
                "card": [
                    "number": "4032036247327321",
                    "security_code": "222",
                    "billing_address": nil,
                    "name": nil,
                    "attributes": [
                        "vault": [
                            "store_in_vault": "ON_SUCCESS"
                        ],
                        "verification": [
                            "method": "SCA_WHEN_REQUIRED"
                        ],
                        "customer": [
                            "id": "testCustomer1"
                        ]
                    ],
                    "expiry": "2024-11"
                ] as [String: Any?]
            ]
        ]
        let paymentSourceDict = try JSONSerialization.jsonObject(with: paymentSourceBody, options: []) as! [String: Any]
        XCTAssertEqual(paymentSourceDict as NSDictionary, expectedPaymentSourceDict as NSDictionary)
    }
    
    func testEncodingPaymentSource_withValidCard_andVaultWithPurchase_noCustomerID() throws {
        let mockOrderID = "mockOrderID"
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )

        let vault = Vault()
        let cardRequest = CardRequest(orderID: mockOrderID, card: card, vault: vault)

        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(clientID: "fake-token", cardRequest: cardRequest)
        )

        let paymentSourceBody = try XCTUnwrap(confirmPaymentSourceRequest.body)
        let expectedPaymentSourceDict: [String: Any] = [
            "application_context": [
                "return_url": "sdk.ios.paypal://card/success",
                "cancel_url": "sdk.ios.paypal://card/cancel"
            ],
            "payment_source": [
                "card": [
                    "number": "4032036247327321",
                    "security_code": "222",
                    "billing_address": NSNull(),
                    "name": NSNull(),
                    "attributes": [
                        "vault": [
                            "store_in_vault": "ON_SUCCESS"
                        ],
                        "verification": [
                            "method": "SCA_WHEN_REQUIRED"
                        ]
                    ],
                    "expiry": "2024-11"
                ] as [String: Any]
            ]
        ]
        let paymentSourceDict = try JSONSerialization.jsonObject(with: paymentSourceBody, options: []) as! [String: Any]
        XCTAssertEqual(paymentSourceDict as NSDictionary, expectedPaymentSourceDict as NSDictionary)
    }
    
    func testEncodingPaymentSource_withValidCard_andVaultWithPurchase_nilCustomerID() throws {
        let mockOrderID = "mockOrderID"
        let card = Card(
            number: "4032036247327321",
            expirationMonth: "11",
            expirationYear: "2024",
            securityCode: "222"
        )

        let vault = Vault(customerID: nil)
        let cardRequest = CardRequest(orderID: mockOrderID, card: card, vault: vault)

        let confirmPaymentSourceRequest = try XCTUnwrap(
            ConfirmPaymentSourceRequest(clientID: "fake-token", cardRequest: cardRequest)
        )

        let paymentSourceBody = try XCTUnwrap(confirmPaymentSourceRequest.body)
        let expectedPaymentSourceDict: [String: Any] = [
            "application_context": [
                "return_url": "sdk.ios.paypal://card/success",
                "cancel_url": "sdk.ios.paypal://card/cancel"
            ],
            "payment_source": [
                "card": [
                    "number": "4032036247327321",
                    "security_code": "222",
                    "billing_address": NSNull(),
                    "name": NSNull(),
                    "attributes": [
                        "vault": [
                            "store_in_vault": "ON_SUCCESS"
                        ],
                        "verification": [
                            "method": "SCA_WHEN_REQUIRED"
                        ]
                    ],
                    "expiry": "2024-11"
                ] as [String: Any]
            ]
        ]
        let paymentSourceDict = try JSONSerialization.jsonObject(with: paymentSourceBody, options: []) as! [String: Any]
        XCTAssertEqual(paymentSourceDict as NSDictionary, expectedPaymentSourceDict as NSDictionary)
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
            ConfirmPaymentSourceRequest(clientID: "fake-token", cardRequest: cardRequest)
        )

        let modifiedClientID = "fake-token" + ":"
        let expectedBase64EncodedClientID = Data(modifiedClientID.utf8).base64EncodedString()
        let expectedPath = "/v2/checkout/orders/\(mockOrderId)/confirm-payment-source"
        let expectedMethod = HTTPMethod.post
        let expectedHeaders: [HTTPHeader: String] = [
            .contentType: "application/json", .acceptLanguage: "en_US",
            .authorization: "Basic \(expectedBase64EncodedClientID)"
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
                clientID: "fake-client-id",
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
