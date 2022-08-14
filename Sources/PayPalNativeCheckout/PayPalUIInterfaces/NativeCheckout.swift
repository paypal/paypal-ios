import Foundation
import UIKit
import PayPalCheckout
#if canImport(PaymentsCore)
import PaymentsCore
#endif

class NativeCheckout: CheckoutProtocol {

    // swiftlint:disable function_parameter_count
    func start(
        presentingViewController: UIViewController? = nil,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?,
        nxoConfig: CheckoutConfig
    ) {
        Checkout.set(config: nxoConfig)
        DispatchQueue.main.async {
            Checkout.start(
                presentingViewController: presentingViewController,
                createOrder: createOrder,
                onApprove: onApprove,
                onShippingChange: onShippingChange,
                onCancel: onCancel,
                onError: onError
            )
        }
    }
    // swift_lint: enable function_parameter_count
}
