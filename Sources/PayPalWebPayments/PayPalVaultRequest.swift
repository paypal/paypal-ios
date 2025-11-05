import Foundation

/// A request to vault a PayPal payment method
public struct PayPalVaultRequest {

    // NEXT_MAJOR_VERSION: - Remove URL property
    /// PayPal approval URL returned as the `href` from the setup token API call
    public let url: URL? = nil

    /// ID for the setup token associated with the vault
    /// Returned as  top level `id` from the setup token API call
    public let setupTokenID: String

    /// Used to determine if the customer will use the PayPal app switch flow
    public let appSwitchIfEligible: Bool

    /// Creates an instance of a PayPal vault request
    /// - Parameters:
    ///    - url: PayPal approval URL returned as the `href` from the setup token API call
    ///    - setupTokenID: An ID for the setup token associated with the vault
    @available(*, deprecated, message: "Use `init(setupTokenID:)` instead.")
    public init(url: URL, setupTokenID: String, appSwitchIfEligible: Bool = false) {
        self.setupTokenID = setupTokenID
        self.appSwitchIfEligible = appSwitchIfEligible
    }

    /// Creates an instance of a PayPal vault request
    /// - Parameter setupTokenID: An ID for the setup token associated with the vault
    public init(setupTokenID: String, appSwitchIfEligible: Bool = false) {
        self.setupTokenID = setupTokenID
        self.appSwitchIfEligible = appSwitchIfEligible
    }
}
