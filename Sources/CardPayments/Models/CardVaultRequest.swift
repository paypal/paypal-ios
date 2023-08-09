import Foundation

public struct CardVaultRequest {
    
    public let card: Card
    public let setupToken: String
    
    public init(card: Card, setupToken: String) {
        self.card = card
        self.setupToken = setupToken
    }
}
