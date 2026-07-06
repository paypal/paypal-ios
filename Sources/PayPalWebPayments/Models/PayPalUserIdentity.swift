import Foundation

/// Buyer identity for Shopper Session creation.
public struct PayPalUserIdentity {

    let shopperSessionID: String?
    let email: String?
    let phone: String?

    private init(shopperSessionID: String?, email: String?, phone: String?) {
        self.shopperSessionID = shopperSessionID
        self.email = email
        self.phone = phone
    }

    public init(shopperSessionID: String) {
        self.init(shopperSessionID: shopperSessionID, email: nil, phone: nil)
    }

    public init(email: String?, phone: String?) {
        self.init(shopperSessionID: nil, email: email, phone: phone)
    }
}
