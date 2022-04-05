import Foundation

/// Used to configure options for approving a PayPal order
public struct PayPalWebCheckoutRequest {

    /// The order ID associated with the request.
    public let orderID: String
    /// The funding for the order: credit, paylater or default
    public let funding: PayPalWebCheckoutFundingSource

    /// Creates an instance of a PayPalRequest.
    /// - Parameter orderID: The ID of the order to be approved.
    public init(orderID: String, funding: PayPalWebCheckoutFundingSource = .unspecified) {
        self.orderID = orderID
        self.funding = funding
    }
}
