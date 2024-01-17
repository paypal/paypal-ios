import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// The result of a vault without purchase flow.
public struct PayPalVaultResult: Decodable, Equatable {

    public let tokenID: String
    public let approvalSessionID: String
}
