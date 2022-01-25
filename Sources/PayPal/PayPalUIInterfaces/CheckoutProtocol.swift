import Foundation
import UIKit

#if canImport(PaymentsCore)
import PaymentsCore
#endif

protocol CheckoutProtocol {
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

