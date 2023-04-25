import Foundation
import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

class NativeCheckoutProvider: NativeCheckoutStartable {

    // swiftlint:disable:next function_parameter_count
    func start(
        presentingViewController: UIViewController? = nil,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?,
        nxoConfig: CheckoutConfig
    ) {
        Checkout.showsExitAlert = false
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
}
