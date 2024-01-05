@testable import CardPayments

enum FakeConfirmPaymentResponse {
    
    static let withValid3DSURL = ConfirmPaymentSourceResponse(
        id: "testOrderId",
        status: "PAYER_ACTION_REQUIRED",
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
                href: "https://fakeURL/helios?flow=3ds",
                rel: "payer-action",
                method: nil
            )
        ]
    )
    
    static let withInvalid3DSURL = ConfirmPaymentSourceResponse(
        id: "testOrderId",
        status: "PAYER_ACTION_REQUIRED",
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
                href: "https://sandbox.paypal.com",
                rel: "payer-action",
                method: nil
            )
        ]
    )
    
    static let without3DS = ConfirmPaymentSourceResponse(
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
}
