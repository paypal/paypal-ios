import Foundation

/// Buyer identity for Shopper Session creation.
public struct PayPalUserIdentity {

    let existingPayPalSessionID: String?
    let email: String?
    let phone: String?

    private init(existingPayPalSessionID: String?, email: String?, phone: String?) {
        self.existingPayPalSessionID = existingPayPalSessionID
        self.email = email
        self.phone = phone
    }

    public init(existingPayPalSessionID: String) {
        self.init(existingPayPalSessionID: existingPayPalSessionID, email: nil, phone: nil)
    }

    public init(email: String?, phone: String?) {
        self.init(existingPayPalSessionID: nil, email: email, phone: phone)
    }
}
