import PayPalCheckout

// Wrapper for PayPalCheckout.ShippingChangeAddress
/// The user's selected shipping address via the PayPal Native Checkout UI.
///
/// If you want to show shipping options in the PayPal Native Paysheet,
/// provide `purchase_units[].shipping.options` when creating an orderID with
/// the [`orders/v2` API](https://developer.paypal.com/docs/api/orders/v2/#definition-purchase_unit) on your server. Otherwise, our Paysheet won't display any shipping options.
public struct PayPalNativeShippingAddress {
    
    /// The ID of the shipping address
    public let addressID: String?
    
    /// The highest level sub-division in a country, which is usually a province, state, or ISO-3166-2 subdivision.
    /// Format for postal delivery. For example, `CA` and not `California`. Value, by country, is:
    /// - UK: A county.
    /// - US: A state.
    /// - Canada: A province.
    /// - Japan: A prefecture.
    /// - Switzerland: A kanton.
    public let adminArea1: String?

    /// The city, town, or village.
    public let adminArea2: String?

    /// The postal code, which is the zip code or equivalent. Typically required for countries with a postal code or an equivalent.
    public let postalCode: String?

    /// The two-character ISO 3166-1 code that identifies the country or region.
    /// For more information, refer to: https://developer.paypal.com/api/rest/reference/country-codes/
    public let countryCode: String?
    
    init(_ shippingChangeAddress: PayPalCheckout.ShippingChangeAddress) {
        self.addressID = shippingChangeAddress.addressID
        self.adminArea1 = shippingChangeAddress.adminArea1
        self.adminArea2 = shippingChangeAddress.adminArea2
        self.postalCode = shippingChangeAddress.postalCode
        self.countryCode = shippingChangeAddress.countryCode
    }
    
    /// For testing
    init(
        addressID: String? = nil,
        adminArea1: String? = nil,
        adminArea2: String? = nil,
        postalCode: String? = nil,
        countryCode: String? = nil
    ) {
        self.addressID = addressID
        self.adminArea1 = adminArea1
        self.adminArea2 = adminArea2
        self.postalCode = postalCode
        self.countryCode = countryCode
    }
}
