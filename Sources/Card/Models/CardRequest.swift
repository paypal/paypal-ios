import Foundation

public struct CardRequest {

    /// The card to be charged for this order
    public let card: Card

    /// Request to start 3DS authentication
    public let threeDSecureRequest: ThreeDSecureRequest?

    /// Creates an instance of a card request
    /// - Parameters:
    ///   - card: The card to be charged for this order
    ///   - threeDSecureRequest: Request to start 3DS authentication
    public init(card: Card, threeDSecureRequest: ThreeDSecureRequest? = nil) {
        self.card = card
        self.threeDSecureRequest = threeDSecureRequest
    }
}
