import Foundation

struct PaymentTokenPaymentSource: Encodable {

    let paymentSource: TokenDetails

    struct TokenDetails: Encodable {

        let token: Token
    }
    struct Token: Encodable {

        let id: String
        let type: String
    }
}
