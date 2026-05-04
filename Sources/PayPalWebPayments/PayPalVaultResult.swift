import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// The result of a vault without purchase flow.
public struct PayPalVaultResult: Decodable, Equatable {

    /// The ID of the vaulted payment token.
    public let tokenID: String
    /// The session ID for the vault approval.
    public let approvalSessionID: String
}
