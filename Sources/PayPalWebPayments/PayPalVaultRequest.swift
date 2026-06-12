import Foundation

/// A request to vault a PayPal payment method.
public struct PayPalVaultRequest {

    public let userIdentity: PayPalUserIdentity?
    public let urlConfig: PayPalURLConfig
    public let userAction: PayPalUserAction

    public init(
        userIdentity: PayPalUserIdentity? = nil,
        urlConfig: PayPalURLConfig,
        userAction: PayPalUserAction = .continue
    ) {
        self.userIdentity = userIdentity
        self.urlConfig = urlConfig
        self.userAction = userAction
    }
}
