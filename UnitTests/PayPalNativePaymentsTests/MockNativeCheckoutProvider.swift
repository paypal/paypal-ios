import Foundation
import UIKit

@testable import PayPalNativePayments
@testable import CorePayments
import PayPalCheckout
import XCTest

class MockNativeCheckoutProvider: NativeCheckoutStartable {

    required init(nxoConfig: CheckoutConfig) {
    }

    var onCancel: StartabeCancelCallback?
    var onError: StartabeErrorCallback?
    var onApprove: StartabeApproveCallback?
    var onShippingChange: StartabeShippingCallback?

    // todo: implemenet cases for other callbacks
    // swiftlint:disable function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        orderID: String,
        onStartableApprove: @escaping StartabeApproveCallback,
        onStartableShippingChange: @escaping StartabeShippingCallback,
        onStartableCancel: @escaping StartabeCancelCallback,
        onStartableError: @escaping StartabeErrorCallback,
        nxoConfig: CheckoutConfig
    ) {
        self.onCancel = onStartableCancel
        self.onError = onStartableError
        self.onApprove = onStartableApprove
        self.onShippingChange = onStartableShippingChange
    }
    // swiftlint:enable function_parameter_count

    func triggerCancel() {
        onCancel?()
    }
    
    func triggerError(errorReason: String) {
        onError?(errorReason)
    }
    
    func triggerApprove(orderdID: String, payerID: String) {
        onApprove?(orderdID, payerID)
    }
    
    func triggerShippingChange(
        type: ShippingChangeType,
        actions: PayPalNativeShippingActions,
        address: PayPalNativeShippingAddress,
        method: PayPalNativeShippingMethod) {
        onShippingChange?(type, actions, address, method)
    }
}
