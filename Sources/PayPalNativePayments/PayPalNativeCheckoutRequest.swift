import Foundation

/// Used to configure options for approving a PayPal native order
public struct PayPalNativeCheckoutRequest {

    /// The order ID associated with the request.
    public let orderID: String

    /// Optional. User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    public let userAuthenticationEmail: String?
    
    /// Creates an instance of a PayPalNativeCheckoutRequest.
    /// - Parameter orderID: The ID of the order to be approved.
    /// - Parameter userAuthenticationEmail: Optional. User email to initiate a quicker authentication flow in cases where the user has a PayPal Account with the same email.
    public init(orderID: String, userAuthenticationEmail: String? = nil) {
        self.orderID = orderID
        self.userAuthenticationEmail = userAuthenticationEmail
    }
}
