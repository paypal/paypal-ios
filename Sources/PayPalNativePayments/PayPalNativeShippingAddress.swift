import PayPalCheckout

// Wrapper for PayPalCheckout.ShippingChangeAddress
/// The user's selected shipping address via the PayPal Native Checkout UI.
public struct PayPalNativeShippingAddress {
    
    /// The ID of the shipping address
    public internal(set) var addressID: String?
    
    /// The highest level sub-division in a country, which is usually a province, state, or ISO-3166-2 subdivision.
    /// Format for postal delivery. For example, `CA` and not `California`. Value, by country, is:
    /// - UK: A county.
    /// - US: A state.
    /// - Canada: A province.
    /// - Japan: A prefecture.
    /// - Switzerland: A kanton.
    public internal(set) var adminArea1: String?

    /// The city, town, or village.
    public internal(set) var adminArea2: String?

    /// The postal code, which is the zip code or equivalent. Typically required for countries with a postal code or an equivalent.
    public internal(set) var postalCode: String?

    /// The two-character ISO 3166-1 code that identifies the country or region.
    /// For more information, refer to: https://developer.paypal.com/api/rest/reference/country-codes/
    public internal(set) var countryCode: String?
    
    init(_ shippingChangeAddress: PayPalCheckout.ShippingChangeAddress) {
        self.addressID = shippingChangeAddress.addressID
        self.adminArea1 = shippingChangeAddress.adminArea1
        self.adminArea2 = shippingChangeAddress.adminArea2
        self.postalCode = shippingChangeAddress.postalCode
        self.countryCode = shippingChangeAddress.countryCode
    }
}
