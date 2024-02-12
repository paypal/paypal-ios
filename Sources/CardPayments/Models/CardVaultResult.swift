import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// The result of a vault without purchase flow.
public struct CardVaultResult {
    
    /// setupTokenID of token that was updated
    public let setupTokenID: String

    /// setupToken status
    public let status: String?

    /// This is the deep link url returned from 3DS authentication
    @_documentation(visibility: private)
    public let deepLinkURL: URL?
}
