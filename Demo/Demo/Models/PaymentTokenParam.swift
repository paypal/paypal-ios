import Foundation

struct PaymentTokenParam: Encodable {

    let paymentSource: PaymentSource

    struct PaymentSource: Encodable {

        let token: Token

        init(setupTokenID: String) {
            token = Token(id: setupTokenID)
        }
    }

    struct Token: Encodable {

        let id: String
        let type = "SETUP_TOKEN"
    }
}
