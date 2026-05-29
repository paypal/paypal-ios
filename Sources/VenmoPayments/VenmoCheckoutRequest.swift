import Foundation

/// Used to configure options for approving a Venmo order.
public struct VenmoCheckoutRequest {

    /// The order ID associated with the request.
    public let orderID: String

    /// The buyer's country code. Defaults to `"US"`.
    public let buyerCountry: String

    /// The currency code for the transaction. Defaults to `"USD"`.
    public let currency: String

    /// Creates an instance of a `VenmoCheckoutRequest`.
    /// - Parameters:
    ///   - orderID: The ID of the order to be approved.
    ///   - buyerCountry: The buyer's country code. Defaults to `"US"`.
    ///   - currency: The currency code for the transaction. Defaults to `"USD"`.
    public init(orderID: String, buyerCountry: String = "US", currency: String = "USD") {
        self.orderID = orderID
        self.buyerCountry = buyerCountry
        self.currency = currency
    }
}
