import Foundation
import UIKit
import PayPalCheckout
import PaymentsCore

protocol CheckoutProtocol {

    init(nxoConfig: CheckoutConfig)

    // swiftlint:disable function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?
    )
    // swiftlint:enable function_parameter_count
}
