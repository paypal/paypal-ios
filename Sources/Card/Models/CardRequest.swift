import Foundation

public struct CardRequest {

    /// The order to approve
    public let orderID: String

    /// The card to be charged for this order
    public let card: Card

    /// 3DS authentication launch option
    public let sca: SCA
    
    /// Creates an instance of a card request
    /// - Parameters:
    ///    - orderID: The order to be approved
    ///    - card: The card to be charged for this order
    ///    - sca: Specificy to always launch 3DS or only when required. Defaults to `scaWhenRequired`.
    public init(orderID: String, card: Card, sca: SCA = .scaWhenRequired) {
        self.orderID = orderID
        self.card = card
        self.sca = sca
    }
}
