import Foundation

struct PaymentTokenPaymentSource: Encodable {

    struct TokenDetails: Encodable {

        let token: Token
    }
    struct Token: Encodable {

        let id: String
        let type: String
    }
    let paymentSource: TokenDetails
}
