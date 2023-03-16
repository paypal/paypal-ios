// TODO: - Copied from NXO ShippingChangeAddress
public struct ShippingAddress {
    
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
    
    init(addressID: String? = nil,
         fullName: String? = nil,
         adminArea1: String? = nil,
         adminArea2: String? = nil,
         adminArea3: String? = nil,
         adminArea4: String? = nil,
         postalCode: String? = nil,
         countryCode: String? = nil
    ) {
        self.addressID = addressID
        self.fullName = fullName
        self.adminArea1 = adminArea1
        self.adminArea2 = adminArea2
        self.adminArea3 = adminArea3
        self.adminArea4 = adminArea4
        self.postalCode = postalCode
        self.countryCode = countryCode
    }
}
