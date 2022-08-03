import Foundation
import UIKit

@testable import PayPalNativeCheckout
@testable import PaymentsCore

class MockCheckout: CheckoutProtocol {

    static var onApprove: ApprovalCallback?
    static var onCancel: CancelCallback?
    static var onError: ErrorCallback?

    static func set(config: CoreConfig) { }

    static func start(
        presentingViewController: UIViewController?,
        createOrder: CreateOrderCallback?,
        onApprove: ApprovalCallback?,
        onCancel: CancelCallback?,
        onError: ErrorCallback?
    ) {
        self.onApprove = onApprove
        self.onCancel = onCancel
        self.onError = onError
    }

    static func triggerApproval(approval: MockApproval) {
        onApprove?(approval)
    }

    static func triggerCancel() {
        onCancel?()
    }

    static func triggerError(error: PayPalCheckoutErrorInfo) {
        onError?(error)
    }
}

// swiftlint:disable space_after_main_type
struct MockApproval: PayPalCheckoutApprovalData {
    var intent: String
    var payerID: String
    var ecToken: String
}

struct MockPayPalError: PayPalCheckoutErrorInfo {
    var reason: String
    var error: Error
}
// swiftlint:enable space_after_main_type
