import Foundation
import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

protocol NativeCheckoutStartable {
    
    typealias StartabeApproveCallback = (String, String) -> Void
    typealias StartabeShippingCallback = (
        ShippingChangeType,
        PayPalNativePaysheetActions,
        PayPalNativeShippingAddress,
        PayPalNativeShippingMethod?
    ) -> Void
    typealias StartabeCancelCallback = () -> Void
    typealias StartabeErrorCallback = (String) -> Void


    // swiftlint:disable:next function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        orderID: String,
        onStartableApprove: @escaping StartabeApproveCallback,
        onStartableShippingChange: @escaping StartabeShippingCallback,
        onStartableCancel: @escaping StartabeCancelCallback,
        onStartableError: @escaping StartabeErrorCallback,
        nxoConfig: CheckoutConfig
    )
}
