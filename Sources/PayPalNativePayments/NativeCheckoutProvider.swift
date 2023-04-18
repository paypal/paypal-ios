import Foundation
import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

class NativeCheckoutProvider: NativeCheckoutStartable {

    // swiftlint:disable:next function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        orderID: String,
        onStartableApprove: @escaping StartabeApproveCallback,
        onStartableShippingChange: @escaping StartabeShippingCallback,
        onStartableCancel: @escaping StartabeCancelCallback,
        onStartableError: @escaping StartabeErrorCallback,
        nxoConfig: CheckoutConfig
    ) {
        Checkout.showsExitAlert = false
        Checkout.set(config: nxoConfig)
        DispatchQueue.main.async {
            Checkout.start(
                presentingViewController: presentingViewController,
                createOrder: { createOrderAction in
                    createOrderAction.set(orderId: orderID)
                },
                onApprove: { approval in
                    onStartableApprove(approval.data.ecToken, approval.data.payerID)
                },
                onShippingChange: { shippingChangeData, shippingChangeActions in
                    let type = shippingChangeData.type
                    let shippingActions = PayPalNativeShippingActions(shippingChangeActions)
                    let shippingAddress = PayPalNativeShippingAddress(shippingChangeData.selectedShippingAddress)
                    var shippingMethod: PayPalNativeShippingMethod?
                    if let selectedMethod = shippingChangeData.selectedShippingMethod {
                        shippingMethod = PayPalNativeShippingMethod(selectedMethod)
                    }
                    onStartableShippingChange(type, shippingActions, shippingAddress, shippingMethod)
                },
                onCancel: { onStartableCancel() },
                onError: { error in
                    onStartableError(error.reason)
                }
            )
        }
    }
}
