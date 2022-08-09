
import Foundation
import UIKit
@_implementationOnly import PayPalCheckout
import PaymentsCore

class NativeCheckout: CheckoutProtocol {

    let nxoConfig: CheckoutConfig
    required internal init(nxoConfig: CheckoutConfig) {
        self.nxoConfig = nxoConfig
    }


    func start(presentingViewController: UIViewController?,
                    createOrder: CheckoutConfig.CreateOrderCallback?,
                    onApprove: CheckoutConfig.ApprovalCallback?,
                    onShippingChange: CheckoutConfig.ShippingChangeCallback?,
                    onCancel: CheckoutConfig.CancelCallback?,
                    onError: CheckoutConfig.ErrorCallback?) {
        Checkout.set(config: nxoConfig)
        Checkout.start(presentingViewController: presentingViewController, createOrder: createOrder, onApprove: onApprove, onShippingChange: onShippingChange, onCancel: onCancel, onError: onError)
    }


}
