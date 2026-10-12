import Foundation

struct ApplePayConfig: Decodable, Equatable {

    let isEligible: Bool
    let merchantCountry: String
    let merchantCapabilities: [String]
    let supportedNetworks: [String]
    let tokenNotificationURL: String?
}

struct ApplePayPaymentMethod: Encodable {

    let displayName: String?
    let network: String?
    let type: String?
}

struct ApplePayPaymentToken: Encodable {

    let paymentData: JSONValue
    let paymentMethod: ApplePayPaymentMethod
    let transactionIdentifier: String
}

/// Apple Pay contact, in the shape `ApproveApplePayPayment` expects.
struct ApplePayPaymentContact: Encodable {

    var phoneNumber: String?
    var emailAddress: String?
    var givenName: String?
    var familyName: String?
    var phoneticGivenName: String?
    var phoneticFamilyName: String?
    var addressLines: [String]?
    var subLocality: String?
    var locality: String?
    var postalCode: String?
    var subAdministrativeArea: String?
    var administrativeArea: String?
    var country: String?
    var countryCode: String?

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(emailAddress, forKey: .emailAddress)
        try container.encodeIfPresent(givenName, forKey: .givenName)
        try container.encodeIfPresent(familyName, forKey: .familyName)
        try container.encodeIfPresent(phoneticGivenName, forKey: .phoneticGivenName)
        try container.encodeIfPresent(phoneticFamilyName, forKey: .phoneticFamilyName)
        try container.encodeIfPresent(addressLines, forKey: .addressLines)
        try container.encodeIfPresent(subLocality, forKey: .subLocality)
        try container.encodeIfPresent(locality, forKey: .locality)
        try container.encodeIfPresent(postalCode, forKey: .postalCode)
        try container.encodeIfPresent(subAdministrativeArea, forKey: .subAdministrativeArea)
        try container.encodeIfPresent(administrativeArea, forKey: .administrativeArea)
        try container.encodeIfPresent(country, forKey: .country)
        if let countryCode {
            try container.encode(countryCode.uppercased(), forKey: .countryCode)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case phoneNumber
        case emailAddress
        case givenName
        case familyName
        case phoneticGivenName
        case phoneticFamilyName
        case addressLines
        case subLocality
        case locality
        case postalCode
        case subAdministrativeArea
        case administrativeArea
        case country
        case countryCode
    }
}

struct ApplePayAuthorization {

    let token: ApplePayPaymentToken
    let billingContact: ApplePayPaymentContact
    let shippingContact: ApplePayPaymentContact?
}
