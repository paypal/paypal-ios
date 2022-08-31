import Foundation
import UIKit

@testable import PayPalNativeCheckout
@testable import PaymentsCore
import PayPalCheckout
import XCTest

class MockNativeCheckoutProvider: NativeCheckoutStartable {

    required init(nxoConfig: CheckoutConfig) {
    }

    var onCancel: CheckoutConfig.CancelCallback?
    var onError: CheckoutConfig.ErrorCallback?

    // todo: implemenet cases for other callbacks
    // swiftlint:disable function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: CheckoutConfig.ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CheckoutConfig.CancelCallback?,
        onError: CheckoutConfig.ErrorCallback?,
        nxoConfig: CheckoutConfig
    ) {
        self.onCancel = onCancel
        self.onError = onError
    }
    // swiftlint:enable function_parameter_count

    func triggerCancel() {
        onCancel?()
    }
}
