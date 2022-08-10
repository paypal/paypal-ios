import Foundation
import UIKit
import PayPalCheckout
import PaymentsCore

class NativeCheckout: CheckoutProtocol {

    let nxoConfig: CheckoutConfig
    required internal init(nxoConfig: CheckoutConfig) {
        self.nxoConfig = nxoConfig
    }
    // swiftlint:disable function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?
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
