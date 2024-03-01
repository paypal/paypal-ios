import Foundation

/// A request to vault a PayPal payment method
public struct PayPalVaultRequest {

    /// PayPal URL for the approval web page
    public let url: URL

    /// ID for the setup token associated with the vault
    public let setupTokenID: String

    public init(url: URL, setupTokenID: String) {
        self.url = url
        self.setupTokenID = setupTokenID
    }
}
