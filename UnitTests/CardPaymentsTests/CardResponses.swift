@testable import CardPayments

// TODO: - cleanup this file & names
enum FakeConfirmPaymentResponse {
    
    static let jsonWith3DS = ConfirmPaymentSourceResponse(
        id: "testOrderId",
        status: "APPROVED",
        paymentSource: PaymentSource(
            card: PaymentSource.Card(
                lastFourDigits: "7321",
                brand: "VISA",
                type: "CREDIT",
                authenticationResult: nil
            )
        ),
        links: [
            Link(
                href: "https://fakeURL?PayerID=98765",
                rel: "payer-action",
                method: nil
            )
        ]
    )
    
    static let jsonWithInvalid3DSURL = ConfirmPaymentSourceResponse(
        id: "testOrderId",
        status: "APPROVED",
        paymentSource: PaymentSource(
            card: PaymentSource.Card(
                lastFourDigits: "7321",
                brand: "VISA",
                type: "CREDIT",
                authenticationResult: nil
            )
        ),
        links: [
            Link(
                href: "",
                rel: "payer-action",
                method: nil
            )
        ]
    )
    
    static let jsonSuccessWithout3DS = ConfirmPaymentSourceResponse(
        id: "testOrderId",
        status: "APPROVED",
        paymentSource: PaymentSource(
            card: PaymentSource.Card(
                lastFourDigits: "7321",
                brand: "VISA",
                type: "CREDIT",
                authenticationResult: nil
            )
        ),
        links: nil
    )
    
    static let jsonSuccessfulGetOrder = ConfirmPaymentSourceResponse(
        id: "testOrderId",
        status: "APPROVED",
        paymentSource: PaymentSource(
            card: PaymentSource.Card(
                lastFourDigits: "7321",
                brand: "VISA",
                type: "CREDIT",
                authenticationResult: AuthenticationResult(
                    liabilityShift: "POSSIBLE",
                    threeDSecure: ThreeDSecure(
                        enrollmentStatus: "Y",
                        authenticationStatus: "Y"
                    )
                )
            )
        ),
        links: [
            Link(
                href: "https://fakeURL?PayerID=98765",
                rel: "payer-action",
                method: nil
            )
        ]
    )
}

//enum CardResponses: String {
//    case confirmPaymentSourceJson = """
//        {
//            "id": "testOrderId",
//            "status": "APPROVED",
//            "payment_source": {
//                "card": {
//                    "last_four_digits": "7321",
//                    "brand": "VISA",
//                    "type": "CREDIT"
//                }
//            }
//        }
//        """
//
//    case confirmPaymentSourceJsonWith3DS = """
//        {
//            "id": "testOrderId",
//            "status": "APPROVED",
//            "payment_source": {
//                "card": {
//                    "last_four_digits": "7321",
//                    "brand": "VISA",
//                    "type": "CREDIT"
//                }
//            },
//            "links": [
//                {
//                    "rel": "payer-action",
//                    "href": "https://fakeURL?PayerID=98765"
//                }
//            ]
//        }
//        """
//    
//    case confirmPaymentSourceJsonInvalid3DSURL = """
//        {
//            "id": "testOrderId",
//            "status": "APPROVED",
//            "payment_source": {
//                "card": {
//                    "last_four_digits": "7321",
//                    "brand": "VISA",
//                    "type": "CREDIT"
//                }
//            },
//            "links": [
//                {
//                    "rel": "payer-action",
//                    "href": ""
//                }
//            ]
//        }
//        """
//
//    case successfullGetOrderJson = """
//        {
//            "id": "testOrderId",
//            "status": "CREATED",
//            "intent": "CAPTURE",
//            "payment_source": {
//                "card": {
//                    "last_four_digits": "7321",
//                    "brand": "VISA",
//                    "type": "CREDIT",
//                    "authentication_result": {
//                        "liability_shift": "POSSIBLE",
//                            "three_d_secure": {
//                                "enrollment_status": "Y",
//                                "authentication_status": "Y"
//                            }
//                    }
//                }
//            },
//            "links": [
//                {
//                    "rel": "payer-action",
//                    "href": "https://fakeURL?PayerID=98765"
//                }
//            ]
//        }
//        """
//}
