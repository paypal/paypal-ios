import Foundation
import UIKit
@_implementationOnly import PayPalCheckout
import PaymentsCore

protocol PayPalUIFlow {
    typealias CreateOrderCallback = (PayPalCreateOrder) -> Void
    typealias ApprovalCallback = (PayPalCheckoutApprovalData) -> Void
    typealias CancelCallback = () -> Void
    typealias ErrorCallback = (PayPalCheckoutErrorInfo) -> Void

    static func set(config: CoreConfig, returnURL: String)

    static func start(
        presentingViewController: UIViewController?,
        createOrder: CreateOrderCallback?,
        onApprove: ApprovalCallback?,
        onCancel: CancelCallback?,
        onError: ErrorCallback?
    )
}

extension Checkout: PayPalUIFlow {
    static func set(config: CoreConfig, returnURL: String) {
        let nxoConfig = CheckoutConfig(
            clientID: config.clientID,
            returnUrl: returnURL,
            environment: config.environment.toNativeCheckoutSDKEnvironment()
        )
        set(config: nxoConfig)
    }

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
