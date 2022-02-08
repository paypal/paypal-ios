import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
#endif

public protocol PayPalDelegate: AnyObject {

    func paypal(client paypalClient: PayPalClient, didFinishWithResult result: PayPalResult)
    func paypal(client paypalClient: PayPalClient, didFinishWithError error: PayPalSDKError)
    func paypalDidCancel(client paypalClient: PayPalClient)
}
