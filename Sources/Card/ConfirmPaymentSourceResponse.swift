// swiftlint:disable space_after_main_type

import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

struct ConfirmPaymentSourceResponse: Decodable {
    let id: String
    let paymentSource: PaymentSource
}

struct PaymentSource: Decodable {
    let card: PaymentSource.Card

    struct Card: Decodable {
        let lastDigits: String?
        let brand: String?
        let type: String?
    }
}
