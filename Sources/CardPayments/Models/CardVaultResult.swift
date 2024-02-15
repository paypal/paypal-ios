import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// The result of a vault without purchase flow.
public struct CardVaultResult {
    
    /// setupTokenID of token that was updated
    public let setupTokenID: String

    /// setup token status
    public let status: String?

    /// 3DS verification was attempted. Use v3/setup-tokens/{id} in your server to get verification results.
    public let didAttemptThreeDSecureAuthentication: Bool
}
