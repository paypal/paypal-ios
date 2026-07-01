import Foundation

/// Buyer identity for Shopper Session creation.
public enum PayPalUserIdentity {
    case serverSideShopperSession(serverSideShopperSessionId: String)
    case emailPhone(email: String?, phone: String?)
    case none
}
