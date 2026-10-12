import Foundation

/// A line on the Apple Pay sheet.
public struct ApplePaySummaryItem: Equatable {

    public enum Kind: Equatable {
        case final
        case pending
    }

    public let label: String
    public let amount: Decimal
    public let kind: Kind

    public init(label: String, amount: Decimal, kind: Kind = .final) {
        self.label = label
        self.amount = amount
        self.kind = kind
    }
}

/// What the SDK needs to present the Apple Pay sheet for an existing PayPal order.
///
/// Create the order on your server with the Orders v2 API, then pass its ID here.
/// `merchantIdentifier` is the Apple merchant ID from the app's Apple Pay entitlement.
public struct ApplePayRequest: Equatable {

    public let orderID: String
    public let merchantIdentifier: String
    public let currencyCode: String
    public let total: ApplePaySummaryItem
    public var lineItems: [ApplePaySummaryItem]
    public var requiresBillingContact: Bool
    public var requiresShippingContact: Bool
    /// ISO country code sent when loading the merchant's Apple Pay configuration. Optional.
    public var buyerCountry: String?

    public init(
        orderID: String,
        merchantIdentifier: String,
        currencyCode: String,
        total: ApplePaySummaryItem,
        lineItems: [ApplePaySummaryItem] = [],
        requiresBillingContact: Bool = true,
        requiresShippingContact: Bool = false,
        buyerCountry: String? = nil
    ) {
        self.orderID = orderID
        self.merchantIdentifier = merchantIdentifier
        self.currencyCode = currencyCode
        self.total = total
        self.lineItems = lineItems
        self.requiresBillingContact = requiresBillingContact
        self.requiresShippingContact = requiresShippingContact
        self.buyerCountry = buyerCountry
    }
}
