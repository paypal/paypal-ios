import Foundation

public struct CardRequest {

    /// The order to approve
    public let orderID: String

    /// The card to be charged for this order
    public let card: Card

    /// 3DS authentication launch option
    public let sca: SCA
    
    /// The option to vault with purchase
    public let shouldVault: Bool
    
    /// The customerID for vault with purchase option. If left blank, PayPal endpoint will auto-generate one
    public let customerID: String?
    
    /// Creates an instance of a card request
    /// - Parameters:
    ///    - orderID: The order to be approved
    ///    - card: The card to be charged for this order
    ///    - sca: Specificy to always launch 3DS or only when required. Defaults to `scaWhenRequired`.
    ///    - shouldVault: The option to vault the card with purchase. Defaults to `false`.
    ///    - customerID: The customer ID provided by the merchant. Defaults to `nil`.
    public init(orderID: String, card: Card, sca: SCA = .scaWhenRequired, shouldVault: Bool = false, customerID: String? = nil) {
        self.orderID = orderID
        self.card = card
        self.sca = sca
        self.shouldVault = shouldVault
        self.customerID = customerID
    }
}
