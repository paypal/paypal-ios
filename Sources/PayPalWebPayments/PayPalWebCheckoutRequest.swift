import Foundation

/// Used to configure options for approving a PayPal web order.
public struct PayPalWebCheckoutRequest {

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
