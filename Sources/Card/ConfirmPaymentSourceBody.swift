import UIKit
#if canImport(PaymentsCore)
import PaymentsCore
#endif

struct ConfirmPaymentSourceBody: APIRequestBody {

    struct PaymentSource: Encodable {
        let card: Card
    }

    let paymentSource: PaymentSource

    init(card: Card) {
        paymentSource = PaymentSource(card: card)
    }
}
