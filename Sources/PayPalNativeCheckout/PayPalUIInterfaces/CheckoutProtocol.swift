import Foundation
import UIKit
@_implementationOnly import PayPalCheckout
import PaymentsCore

protocol CheckoutProtocol {

    init(nxoConfig: CheckoutConfig)

    func start(presentingViewController: UIViewController?,
                createOrder: CheckoutConfig.CreateOrderCallback?,
                onApprove: CheckoutConfig.ApprovalCallback?,
                onShippingChange: CheckoutConfig.ShippingChangeCallback?,
                onCancel: CheckoutConfig.CancelCallback?,
                onError: CheckoutConfig.ErrorCallback?)
}
