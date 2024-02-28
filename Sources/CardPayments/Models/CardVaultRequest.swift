import Foundation

/// A vault request to attach payment method to setup token
public struct CardVaultRequest {
    
    /// The card for payment source to attach to the setup token
    public let card: Card
    
    /// ID for the setup token to update
    public let setupTokenID: String
    
    /// Creates an instance of a card vault request
    /// - Parameters:
    ///    - card: The card for payment source to attach to the setup token
    ///    - setupTokenID: An ID for the setup token to update
    public init(card: Card, setupTokenID: String) {
        self.card = card
        self.setupTokenID = setupTokenID
    }
}
