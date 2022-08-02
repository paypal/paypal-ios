import Foundation
import UIKit
@_implementationOnly import PayPalCheckout

#if canImport(PaymentsCore)
import PaymentsCore
#endif

protocol CheckoutProtocol {
    typealias CreateOrderCallback = (PayPalCreateOrder) -> Void
    typealias ApprovalCallback = (PayPalCheckoutApprovalData) -> Void
    typealias CancelCallback = () -> Void
    typealias ErrorCallback = (PayPalCheckoutErrorInfo) -> Void

    static func set(config: CoreConfig)

    static func start(
        presentingViewController: UIViewController?,
        createOrder: CreateOrderCallback?,
        onApprove: ApprovalCallback?,
        onCancel: CancelCallback?,
        onError: ErrorCallback?
    )
}

extension Checkout: CheckoutProtocol {

    static func set(config: CoreConfig) {
        let nxoConfig = CheckoutConfig(
            clientID: config.clientID,
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
