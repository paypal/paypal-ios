/// This class is exposed for internal PayPal use only. Do not use.
/// It is not covered by Semantic Versioning and may change or be removed at any time.
@_documentation(visibility: private)
public enum PayPalCoreConstants {

    // TODO: - Update release script to update this version #
    /// This property is exposed for internal PayPal use only. Do not use.
    /// It is not covered by Semantic Versioning and may change or be removed at any time.
    public static let payPalSDKVersion: String = "2.0.1"

    public static let callbackURLScheme: String = "sdk.ios.paypal"
    public static let checkoutCallbackPath: String = "x-callback-url/paypal-sdk/paypal-checkout"

    public static let integrationArtifact: String = "MOBILE_SDK"
    public static let integrationType: String = "MOBILE_SDK"
    public static let platform: String = "iOS"
    public static let integrationChannel: String = "PPCP_NATIVE_SDK"
    public static let paymentMethodPayPal: String = "PAYPAL"
    public static let flowTypeOneTimePayment: String = "ONE_TIME_PAYMENT"
    public static let flowTypeBillingWithoutPurchase: String = "BILLING_WITHOUT_PURCHASE"
    public static let tokenTypeOrderID: String = "ORDER_ID"
    public static let patchCCOFundingSourcePayPal: String = "paypal"
}
