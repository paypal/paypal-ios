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

    /// 3DS verification was attempted. Use v2/checkout/orders/{orderID} in your server to get verification results.
    public let didAttemptThreeDSecureAuthentication: Bool
}
