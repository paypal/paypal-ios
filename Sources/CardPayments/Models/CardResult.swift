import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// The result of a card payment flow.
public struct CardResult {

    /// The order ID associated with the transaction
    public let orderID: String

    /// This is the deep link url returned from 3DS authentication
    @_documentation(visibility: private)
    public let deepLinkURL: URL?
    
    /// Liability shift value returned from 3DS verification
    public let liabilityShift: String?
}
