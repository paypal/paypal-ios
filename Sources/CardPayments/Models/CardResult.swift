import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// The result of a card payment flow.
public struct CardResult {

    /// The order ID associated with the transaction
    public let orderID: String

    //// :nodoc: This is the deep link url returned from 3DS authentication
    // TODO: parse contents of this URL once we are clear on values returned from 3ds
    @_documentation(visibility: private)
    public let deepLinkURL: URL?
}
