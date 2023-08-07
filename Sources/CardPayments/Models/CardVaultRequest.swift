import Foundation
import CorePayments

public struct CardVaultRequest {
    
    public let card: VaultCard
    public let setupToken: String
    
    public init(card: VaultCard, setupToken: String) {
        self.card = card
        self.setupToken = setupToken
    }
}
