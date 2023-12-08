import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// PayPalVault delegate to vault results from PayPalWebCheckoutClient
public protocol PayPalVaultDelegate: AnyObject {

    /// Notify that the PayPal vault flow finished with a successful result
    /// - Parameters:
    ///   - client: the PayPalWebCheckoutClient associated with delegate
    ///   - didFinishWithResult: the successful result from the flow
    func paypal(_ paypalWebClient: PayPalWebCheckoutClient, didFinishWithVaultResult vaultTokenID: String)

    /// Notify that an error occurred in the PayPal vault flow
    /// - Parameters:
    ///   - client: the PayPalWebCheckoutClien associated with delegate
    ///   - didFinishWithError: the error returned by the PayPal vault flow
    func paypal(_ paypalWebClient: PayPalWebCheckoutClient, didFinishWithVaultError vaultError: CoreSDKError)
    
    /// Notify that a cancellation occurred in the PayPal vault flow
    /// - Parameters:
    ///   - client: the PayPalWebCheckoutClien associated with delegate
    func paypalDidCancel(_ paypalWebClient: PayPalWebCheckoutClient)
}
