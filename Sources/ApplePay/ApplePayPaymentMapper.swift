import Contacts
import PassKit

enum ApplePayPaymentMapper {

    static func authorization(from payment: PKPayment) throws -> ApplePayAuthorization {
        ApplePayAuthorization(
            token: try paymentToken(from: payment.token),
            billingContact: contact(from: payment.billingContact) ?? ApplePayPaymentContact(),
            shippingContact: contact(from: payment.shippingContact)
        )
    }

    static func paymentToken(
        paymentData: Data,
        displayName: String?,
        network: String?,
        type: String?,
        transactionIdentifier: String
    ) throws -> ApplePayPaymentToken {
        let json = try JSONSerialization.jsonObject(with: paymentData)
        guard let object = json as? [String: Any] else {
            throw ApplePayError.invalidToken
        }
        return ApplePayPaymentToken(
            paymentData: try JSONValue(json: object),
            paymentMethod: ApplePayPaymentMethod(displayName: displayName, network: network, type: type),
            transactionIdentifier: transactionIdentifier
        )
    }

    static func contact(from contact: PKContact?) -> ApplePayPaymentContact? {
        guard let contact else {
            return nil
        }
        let postal = contact.postalAddress
        let addressLines = postal?.street
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        return ApplePayPaymentContact(
            phoneNumber: contact.phoneNumber?.stringValue,
            emailAddress: contact.emailAddress,
            givenName: contact.name?.givenName,
            familyName: contact.name?.familyName,
            phoneticGivenName: contact.name?.phoneticRepresentation?.givenName,
            phoneticFamilyName: contact.name?.phoneticRepresentation?.familyName,
            addressLines: addressLines?.isEmpty == true ? nil : addressLines,
            subLocality: postal?.subLocality,
            locality: postal?.city,
            postalCode: postal?.postalCode,
            subAdministrativeArea: postal?.subAdministrativeArea,
            administrativeArea: postal?.state,
            country: postal?.country,
            countryCode: postal?.isoCountryCode
        )
    }

    static func methodType(_ type: PKPaymentMethodType) -> String? {
        switch type {
        case .debit:
            return "debit"
        case .credit:
            return "credit"
        case .prepaid:
            return "prepaid"
        case .store:
            return "store"
        case .unknown, .eMoney:
            return nil
        @unknown default:
            return nil
        }
    }

    private static func paymentToken(from token: PKPaymentToken) throws -> ApplePayPaymentToken {
        try paymentToken(
            paymentData: token.paymentData,
            displayName: token.paymentMethod.displayName,
            network: token.paymentMethod.network?.rawValue,
            type: methodType(token.paymentMethod.type),
            transactionIdentifier: token.transactionIdentifier
        )
    }
}
