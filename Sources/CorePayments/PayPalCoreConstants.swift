/// This class is exposed for internal PayPal use only. Do not use.
/// It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public enum PayPalCoreConstants {
    
    // TODO: - Update release script to update this version #
    /// This property is exposed for internal PayPal use only. Do not use.
    /// It is not covered by Semantic Versioning and may change or be removed at any time.
    public static let payPalSDKVersion: String = "2.0.1"
    
    public static let callbackURLScheme: String = "sdk.ios.paypal"
    
    public static let integrationArtifact: String = "MOBILE_SDK"
    
    public static let osType: String = "IOS"
    
    public static let integrationChannel: String = "PPCP_NATIVE_SDK"
}

@_documentation(visibility: private)
public enum ExternalTokenKind {
    public static let orderId = "ORDER_ID"
    public static let clientToken = "CLIENT_TOKEN"
}

/// The type of token supplied to the Shopper Session mutation.
@_documentation(visibility: private)
public enum TokenType {
    /// An order (checkout) token. Maps to `"CHECKOUT_TOKEN"` in the GQL mutation.
    public static let orderID = "CHECKOUT_TOKEN"
    /// A vault ID token. Maps to `"BILLING_TOKEN"` in the GQL mutation.
    public static let vaultID = "BILLING_TOKEN"
    /// A billing token. Maps to `"BILLING_TOKEN"` in the GQL mutation.
    public static let billingToken = "BILLING_TOKEN"
}
