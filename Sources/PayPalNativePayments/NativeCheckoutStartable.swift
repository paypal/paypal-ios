import Foundation
import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

protocol NativeCheckoutStartable {
    
    typealias StartableApproveCallback = (PayPalCheckout.Approval) -> Void
    typealias StartableShippingCallback = (
        ShippingChangeType,
        PayPalNativePaysheetActions,
        PayPalNativeShippingAddress,
        PayPalNativeShippingMethod?
    ) -> Void
    typealias StartableCancelCallback = () -> Void
    typealias StartableErrorCallback = (PayPalCheckout.ErrorInfo) -> Void


    // swiftlint:disable:next function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        orderID: String,
        onStartableApprove: @escaping StartableApproveCallback,
        onStartableShippingChange: @escaping StartableShippingCallback,
        onStartableCancel: @escaping StartableCancelCallback,
        onStartableError: @escaping StartableErrorCallback,
        nxoConfig: CheckoutConfig
    )
}
