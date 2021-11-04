import Foundation
import UIKit
@_implementationOnly import PayPalCheckout

protocol PayPalUIFlow {
    typealias CreateOrderCallback = (PayPalCreateOrder) -> Void
    typealias ApprovalCallback = (PayPalCheckoutApprovalData) -> Void
    typealias CancelCallback = () -> Void
    typealias ErrorCallback = (PayPalCheckoutErrorInfo) -> Void

    static func set(config: CheckoutConfig)

    static func start(
        presentingViewController: UIViewController?,
        createOrder: CreateOrderCallback?,
        onApprove: ApprovalCallback?,
        onCancel: CancelCallback?,
        onError: ErrorCallback?
    )
}

extension Checkout: PayPalUIFlow {
    static func start(
        presentingViewController: UIViewController?,
        createOrder: CreateOrderCallback?,
        onApprove: ApprovalCallback?,
        onCancel: CancelCallback?,
        onError: ErrorCallback?
    ) {
        start(
            presentingViewController: presentingViewController,
            createOrder: createOrder,
            onApprove: onApprove,
            onShippingChange: nil,
            onCancel: onCancel,
            onError: onError
        )
    }
}
