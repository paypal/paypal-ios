import Foundation
import UIKit
import PayPalCheckout
#if canImport(PaymentsCore)
import PaymentsCore
#endif

protocol NativeCheckoutStartable {

    // swiftlint:disable function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?,
        nxoConfig: CheckoutConfig
    )
    // swiftlint:enable function_parameter_count
}
