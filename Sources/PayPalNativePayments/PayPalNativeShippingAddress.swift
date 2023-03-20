import PayPalCheckout

// Wrapper for PayPalCheckout.ShippingChangeAddress
/// The user's selected shipping address via the PayPal Native Checkout UI.
///
/// If you want to show shipping options in the PayPal Native Paysheet,
/// provide `purchase_units[].shipping.options` when creating an orderID with
/// the [`orders/v2` API](https://developer.paypal.com/docs/api/orders/v2/#definition-purchase_unit) on your server. Otherwise, our Paysheet won't display any shipping options.
public struct PayPalNativeShippingAddress {
    
    /// The ID of the shipping address
    public internal(set) var addressID: String?

    /// The full name of the recipient for the shipping address
    public internal(set) var fullName: String?
    
    /// The highest level sub-division in a country, which is usually a province, state, or ISO-3166-2 subdivision.
    /// Format for postal delivery. For example, `CA` and not `California`. Value, by country, is:
    /// - UK: A county.
    /// - US: A state.
    /// - Canada: A province.
    /// - Japan: A prefecture.
    /// - Switzerland: A kanton.
    public internal(set) var adminArea1: String?

    /// The city, town, or village. Smaller than `adminArea1`.
    public internal(set) var adminArea2: String?

    /// A sub-locality, suburb, neighborhood, or district. Smaller than `adminArea2`. Value is:
    /// - Brazil: Suburb, bairro, or neighborhood.
    /// - India: Sub-locality or district. Street name information is not always available but a sub-locality or district can be a very small area.
    public internal(set) var adminArea3: String?

    /// The neighborhood, ward, or district. Smaller than `adminArea3` or sub-locality. Value is:
    /// - The postal sorting code for Guernsey and many French territories, such as French Guiana.
    /// - The fine-grained administrative levels in China.
    public internal(set) var adminArea4: String?
    
    /// The postal code, which is the zip code or equivalent. Typically required for countries with a postal code or an equivalent.
    public internal(set) var postalCode: String?

    /// The two-character ISO 3166-1 code that identifies the country or region.
    /// For more information, refer to: https://developer.paypal.com/api/rest/reference/country-codes/
    public internal(set) var countryCode: String?
    
    init(_ shippingChangeAddress: PayPalCheckout.ShippingChangeAddress) {
        self.addressID = shippingChangeAddress.addressID
        self.fullName = shippingChangeAddress.fullName
        self.adminArea1 = shippingChangeAddress.adminArea1
        self.adminArea2 = shippingChangeAddress.adminArea2
        self.adminArea3 = shippingChangeAddress.adminArea3
        self.adminArea4 = shippingChangeAddress.adminArea4
        self.postalCode = shippingChangeAddress.postalCode
        self.countryCode = shippingChangeAddress.countryCode
    }
}
