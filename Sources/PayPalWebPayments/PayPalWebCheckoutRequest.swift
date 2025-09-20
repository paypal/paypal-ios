import Foundation

/// Used to configure options for approving a PayPal web order
public struct PayPalWebCheckoutRequest {

    /// The order ID associated with the request.
    public let orderID: String
    /// The funding for the order: credit, paylater or default
    public let fundingSource: PayPalWebCheckoutFundingSource
    /// Used to determine if the customer will use the PayPal app switch flow
    public let appSwitchIfEligible: Bool

    /// Creates an instance of a PayPalRequest.
    /// - Parameter orderID: The ID of the order to be approved.
    /// - Parameter fundingSource: The funding source for and order. Default value is .paypal
    public init(orderID: String, fundingSource: PayPalWebCheckoutFundingSource = .paypal, appSwitchIfEligible: Bool = false) {
        self.orderID = orderID
        self.fundingSource = fundingSource
        self.appSwitchIfEligible = appSwitchIfEligible
    }
}
