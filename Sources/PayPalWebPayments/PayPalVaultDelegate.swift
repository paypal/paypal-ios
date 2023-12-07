import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

public protocol PayPalVaultDelegate: AnyObject {

    func paypal(_ paypalWebClient: PayPalWebCheckoutClient, didFinishWithVaultResult vaultTokenID: String)

    func paypal(_ paypalWebClient: PayPalWebCheckoutClient, didFinishWithVaultError vaultError: CoreSDKError)
    
    func paypalDidCancel(_ paypalWebClient: PayPalWebCheckoutClient)
}
