import Foundation

public struct CardRequest {

    /// The order to approve
    public let orderID: String

    /// The card to be charged for this order
    public let card: Card

    /// Request to start 3DS authentication
    public let threeDSecureRequest: ThreeDSecureRequest?

    /// Creates an instance of a card request
    /// - Parameters:
    ///    - orderId: The order to be approved
    ///    - card: The card to be charged for this order
    ///    - threeDSecureRequest: Request to start 3DS authentication
    public init(orderId: String, card: Card, threeDSecureRequest: ThreeDSecureRequest? = nil) {
        self.orderId = orderId
        self.card = card
        self.threeDSecureRequest = threeDSecureRequest
    }
}
