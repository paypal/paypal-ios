import Foundation

/// Used to configure options for a Venmo checkout transaction.
public struct VenmoCheckoutRequest {

    /// The order ID associated with the request.
    public let orderID: String

    /// Whether to switch to the Venmo app for approval when the app is installed.
    /// When `false` (default), checkout is presented in a web authentication session.
    public let appSwitchIfEligible: Bool

    /// The buyer's country code. Defaults to `"US"`.
    public let buyerCountry: String

    /// The currency code for the transaction. Defaults to `"USD"`.
    public let currency: String

    /// The app return URL forwarded to the Venmo app switch as the `pageUrl` query parameter.
    /// The Venmo pay sheet uses it to bootstrap and to return to your app; typically this matches
    /// the `returnUrl` set on the order's experience context. When `nil`, `pageUrl` is omitted.
    public let returnURL: String?

    /// Creates an instance of a `VenmoCheckoutRequest`.
    /// - Parameters:
    ///   - orderID: The ID of the order to be approved.
    ///   - appSwitchIfEligible: Whether to switch to the Venmo app when installed. Defaults to `false`.
    ///   - buyerCountry: The buyer's country code. Defaults to `"US"`.
    ///   - currency: The currency code for the transaction. Defaults to `"USD"`.
    ///   - returnURL: The app return URL passed to the Venmo app switch as `pageUrl`. Defaults to `nil`.
    public init(
        orderID: String,
        appSwitchIfEligible: Bool = false,
        buyerCountry: String = "US",
        currency: String = "USD",
        returnURL: String? = nil
    ) {
        self.orderID = orderID
        self.appSwitchIfEligible = appSwitchIfEligible
        self.buyerCountry = buyerCountry
        self.currency = currency
        self.returnURL = returnURL
    }
}
