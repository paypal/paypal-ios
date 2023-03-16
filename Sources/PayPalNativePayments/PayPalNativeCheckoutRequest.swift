import Foundation

/// Used to configure options for approving a PayPal native order
public struct PayPalNativeCheckoutRequest {

    /// The order ID associated with the request.
    public let orderID: String
    
    /// Creates an instance of a PayPalNativeCheckoutRequest.
    /// - Parameter orderID: The ID of the order to be approved.
    public init(orderID: String) {
        self.orderID = orderID
    }
    
    // TODO: - do we want to add billing agreement token or vault approval session ID? These are available to set on NXO
}
