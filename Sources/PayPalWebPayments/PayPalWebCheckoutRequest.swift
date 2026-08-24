import Foundation

/// Used to configure options for approving a PayPal web order
public struct PayPalWebCheckoutRequest {

    /// The order ID associated with the request.
    public let orderID: String
    /// The funding for the order: credit, paylater or default
    public let fundingSource: PayPalWebCheckoutFundingSource
    /// Used to determine if the customer will use the PayPal app switch flow
    public let appSwitchIfEligible: Bool

    /// The custom URL scheme your app registers to receive the checkout return.
    /// Defaults to the PayPal SDK's shared scheme (`sdk.ios.paypal`) if not provided. If your app
    /// already uses a custom URL scheme for other purposes, or another integrated SDK registers
    /// the same scheme, provide your own here to avoid a scheme collision.
    public let returnURLScheme: String?

    /// Creates an instance of a PayPalRequest.
    /// - Parameter orderID: The ID of the order to be approved.
    /// - Parameter fundingSource: The funding source for and order. Default value is .paypal
    /// - Parameter appSwitchIfEligible: Whether to switch to the PayPal app when installed. Defaults to `false`.
    /// - Parameter returnURLScheme: The custom URL scheme your app registers to receive the checkout return.
    ///                              Defaults to the PayPal SDK's shared scheme if not provided.
    public init(
        orderID: String,
        fundingSource: PayPalWebCheckoutFundingSource = .paypal,
        appSwitchIfEligible: Bool = false,
        returnURLScheme: String? = nil
    ) {
        self.orderID = orderID
        self.fundingSource = fundingSource
        self.appSwitchIfEligible = appSwitchIfEligible
        self.returnURLScheme = returnURLScheme
    }
}
