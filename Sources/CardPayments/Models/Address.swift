import Foundation

/// The postal address.
public struct Address: Codable, Equatable {

    enum CodingKeys: String, CodingKey {
        case addressLine1
        case addressLine2
        case locality = "admin_area_2"
        case region = "admin_area_1"
        case postalCode
        case countryCode
    }

    /// Optional. The first line of the address.
    public var addressLine1: String?

    /// Optional. The second line of the address.
    public var addressLine2: String?

    /// Optional. A city, town, or village. Smaller than `region`.
    public var locality: String?

    /// Optional. The highest level sub-division in a country, which is usually a province or state. Format for postal delivery, for example, `CA` and not `California`. Value, by country, is:
    /// - UK: a county.
    /// - US: a state.
    /// - Canada: a province.
    /// - Japan: a prefecture.
    /// - Switzerland: a kanton.
    public var region: String?

    /// Optional. The postal code, which is the zip code or equivalent. Typically required for countries with a postal code or an equivalent.
    /// See [postal code](https://en.wikipedia.org/wiki/Postal_code).
    public var postalCode: String?

    /// The [two-character ISO 3166-1 code](/docs/integration/direct/rest/country-codes/) that identifies the country or region.
    /// Note:
    /// - The country code for Great Britain is GB and not UK as used in the top-level domain names for that country. Use the `C2` country code for China worldwide for comparable uncontrolled price (CUP) method, bank card, and cross-border transactions.
    public var countryCode: String

    public init(
        addressLine1: String? = nil,
        addressLine2: String? = nil,
        locality: String? = nil,
        region: String? = nil,
        postalCode: String? = nil,
        countryCode: String
    ) {
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.locality = locality
        self.region = region
        self.postalCode = postalCode
        self.countryCode = countryCode
    }
}
