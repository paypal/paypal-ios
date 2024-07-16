import Foundation

/// Used to configure options for approving a Venmo Checkout order
public struct VenmoCheckoutRequest {
    
    /// The order ID associated with the request
    public let orderID: String
    
    /// Creates an instance of VenmoCheckoutRequest
    ///  - Parameter orderID: The ID of an order to be approved
    public init(orderID: String) {
        self.orderID = orderID
    }
}
