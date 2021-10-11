import Foundation

/// The portable international postal address.
/// Maps to [AddressValidationMetadata](https://github.com/googlei18n/libaddressinput/wiki/AddressValidationMetadata)
/// and HTML 5.1 [Autofilling form controls: the autocomplete attribute](https://www.w3.org/TR/html51/sec-forms.html#autofilling-form-controls-the-autocomplete-attribute).
public class Address: Codable {

    /// The first line of the address. For example, number or street. For example, `173 Drury Lane`.
    /// Required for data entry and compliance and risk checks. Must contain the full address.
    var addressLine1: String?

    /// The second line of the address. For example, suite or apartment number.
    var addressLine2: String?

    /// A city, town, or village. Smaller than `admin_area_level_1`.
    var adminArea2: String?

    /// The highest level sub-division in a country, which is usually a province, state, or ISO-3166-2 subdivision. Format for postal delivery. For example, `CA` and not `California`. Value, by country, is:
    /// - UK: a county.
    /// - US: a state.
    /// - Canada: a province.
    /// - Japan: a prefecture.
    /// - Switzerland: a kanton.
    var adminArea1: String?

    /// The postal code, which is the zip code or equivalent. Typically required for countries with a postal code or an equivalent.
    /// See [postal code](https://en.wikipedia.org/wiki/Postal_code).
    var postalCode: String?

    /// The [two-character ISO 3166-1 code](/docs/integration/direct/rest/country-codes/) that identifies the country or region.
    /// Note:
    /// - The country code for Great Britain is GB and not UK as used in the top-level domain names for that country. Use the `C2` country code for China worldwide for comparable uncontrolled price (CUP) method, bank card, and cross-border transactions.
    var countryCode: String
}
