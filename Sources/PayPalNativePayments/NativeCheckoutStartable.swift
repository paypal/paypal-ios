import Foundation
import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

protocol NativeCheckoutStartable {

    /// Used in POST body for FPTI analytics.
    var correlationID: String? { get set }

    typealias StartableApproveCallback = (String, String) -> Void
    typealias StartableShippingCallback = (
        ShippingChangeType,
        PayPalNativePaysheetActions,
        PayPalNativeShippingAddress,
        PayPalNativeShippingMethod?
    ) -> Void
    typealias StartableCancelCallback = () -> Void
    typealias StartableErrorCallback = (String) -> Void

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
