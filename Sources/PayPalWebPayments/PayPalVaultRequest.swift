import Foundation

/// A request to vault a PayPal payment method
public struct PayPalVaultRequest {

    /// PayPal URL for the approval web page
    public let url: URL

    /// ID for the setup token associated with the vault
    public let setupTokenID: String

    /// Creates an instance of a PayPal vault request
    /// - Parameters:
    ///    - url: The PayPal URL for the approval web page
    ///    - setupTokenID: An ID for the setup token to update
    public init(url: URL, setupTokenID: String) {
        self.url = url
        self.setupTokenID = setupTokenID
    }
}
