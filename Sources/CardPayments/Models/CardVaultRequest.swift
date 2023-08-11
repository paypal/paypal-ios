import Foundation

public struct CardVaultRequest {
    
    public let card: Card
    public let setupTokenID: String
    
    public init(card: Card, setupTokenID: String) {
        self.card = card
        self.setupTokenID = setupTokenID
    }
}
