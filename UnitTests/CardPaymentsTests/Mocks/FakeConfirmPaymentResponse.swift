@testable import CardPayments

enum FakeConfirmPaymentResponse {
    
    static let withValid3DSURL = ConfirmPaymentSourceResponse(
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
    
    static let withInvalid3DSURL = ConfirmPaymentSourceResponse(
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
