import Foundation

public struct VaultRequest {
    
    public let card: Card
    public let customerID: String?
    
    public init(card: Card, customerID: String? = nil) {
        self.card = card
        self.customerID = customerID
    }
}
