// swiftlint:disable space_after_main_type

import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

struct ConfirmPaymentSourceResponse: Decodable {
    let id, status: String
    let paymentSource: PaymentSource?
    let links: [Link]?
}
