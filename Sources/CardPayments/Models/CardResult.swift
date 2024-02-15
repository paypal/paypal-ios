import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// The result of a card payment flow.
public struct CardResult {

    /// The order ID associated with the transaction
    public let orderID: String

    /// status of the order
    public let status: String?

    /// Liability shift value returned from 3DS verification
    public let threeDSecureAttempted: Bool
}
