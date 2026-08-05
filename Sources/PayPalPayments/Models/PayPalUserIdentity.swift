import Foundation

/// Buyer identity for Shopper Session creation.
public struct PayPalUserIdentity {

    let existingPayPalSessionID: String?
    let email: String?
    let phone: PayPalPhoneNumber?

    private init(existingPayPalSessionID: String?, email: String?, phone: PayPalPhoneNumber?) {
        self.existingPayPalSessionID = existingPayPalSessionID
        self.email = email
        self.phone = phone
    }

    public init(existingPayPalSessionID: String) {
        self.init(existingPayPalSessionID: existingPayPalSessionID, email: nil, phone: nil)
    }

    public init(email: String?, phone: PayPalPhoneNumber?) {
        self.init(existingPayPalSessionID: nil, email: email, phone: phone)
    }
}

public struct PayPalPhoneNumber {

    public var countryCode: String
    public var nationalNumber: String

    public init(countryCode: String, nationalNumber: String) {
        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
    }
}
