import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// The result of a vault without purchase flow.
@_documentation(visibility: private)
public struct CardVaultResult {
    
    /// setupTokenID of token that was updated
    public let setupTokenID: String
    
    /// status of the updated setup token
    public let status: String
}
