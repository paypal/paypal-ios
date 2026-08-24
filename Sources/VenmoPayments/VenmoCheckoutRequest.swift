import Foundation

/// Used to configure options for a Venmo checkout transaction.
public struct VenmoCheckoutRequest {

    /// The order ID associated with the request.
    public let orderID: String

    /// Whether to switch to the Venmo app for approval when the app is installed.
    /// When `false` (default), checkout is presented in a web authentication session.
    public let appSwitchIfEligible: Bool

    /// The currency code for the transaction. Defaults to `"USD"`.
    public let currency: String

    /// Creates an instance of a `VenmoCheckoutRequest`.
    /// - Parameters:
    ///   - orderID: The ID of the order to be approved.
    ///   - appSwitchIfEligible: Whether to switch to the Venmo app when installed. Defaults to `false`.
    ///   - currency: The currency code for the transaction. Defaults to `"USD"`.
    public init(
        orderID: String,
        appSwitchIfEligible: Bool = false,
        currency: String = "USD"
    ) {
        self.orderID = orderID
        self.appSwitchIfEligible = appSwitchIfEligible
        self.currency = currency
    }
}
