// swiftlint:disable space_after_main_type

import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

/// tool used:  https://app.quicktype.io/#l=swift
struct ConfirmPaymentSourceResponse: Decodable {
    let id, status: String
    let paymentSource: PaymentSource?
    let links: [Link]?
}

struct PaymentSource: Decodable {
    let card: PaymentSource.Card

    struct Card: Decodable {
        let lastDigits: String?
        let brand: String?
        let type: String?
    }
}

struct Link: Decodable {
    let href: String?
    let rel, method: String?
}
