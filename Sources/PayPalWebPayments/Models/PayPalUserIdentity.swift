import Foundation

/// Buyer identity for Shopper Session creation.
public struct PayPalUserIdentity {

    public let serverSideShopperSessionId: String?
    public let email: String?
    public let phone: String?

    /// Option A: server-created shopper session id.
    public init(serverSideShopperSessionId: String) {
        self.serverSideShopperSessionId = serverSideShopperSessionId
        self.email = nil
        self.phone = nil
    }

    /// Option B: hashed or raw buyer contact hints.
    public init(email: String? = nil, phone: String? = nil) {
        self.serverSideShopperSessionId = nil
        self.email = email
        self.phone = phone
    }
}
