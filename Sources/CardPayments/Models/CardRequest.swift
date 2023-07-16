import Foundation

public struct CardRequest {

    /// The order to approve
    public let orderID: String

    /// The card to be charged for this order
    public let card: Card

    /// 3DS authentication launch option
    public let sca: SCA
    
    /// Vault is a struct with optional customerID that indicates option to vault a card in checkout
    public let vault: Vault?
    
    /// Creates an instance of a card request
    /// - Parameters:
    ///    - orderID: The order to be approved
    ///    - card: The card to be charged for this order
    ///    - sca: Specificy to always launch 3DS or only when required. Defaults to `scaWhenRequired`.
    ///    - vault: The vault object contains optional customerID and passed in when vaulting option is selected in checkout
    public init(orderID: String, card: Card, sca: SCA = .scaWhenRequired, vault: Vault? = nil) {
        self.orderID = orderID
        self.card = card
        self.sca = sca
        self.vault = vault
    }
}
