import Foundation

/// A request to vault a PayPal payment method
public struct PayPalVaultRequest {

    /// ID for the setup token associated with the vault
    /// Returned as  top level `id` from the setup token API call
    public let setupTokenID: String

    /// Creates an instance of a PayPal vault request
    /// - Parameter setupTokenID: An ID for the setup token associated with the vault
    public init(setupTokenID: String) {
        self.setupTokenID = setupTokenID
    }
}
