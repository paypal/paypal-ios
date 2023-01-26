// swiftlint:disable space_after_main_type

import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

struct ConfirmPaymentSourceResponse: Decodable {
    let id, status: String
    let paymentSource: PaymentSource?
    let links: [Link]?
}
