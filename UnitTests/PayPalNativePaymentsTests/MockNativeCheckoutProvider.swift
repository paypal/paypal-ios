import Foundation
import UIKit

@testable import PayPalNativePayments
@testable import CorePayments
import PayPalCheckout
import XCTest

class MockNativeCheckoutProvider: NativeCheckoutStartable {

    var correlationID: String?
    var userAuthenticationEmail: String? = nil
    var onCancel: StartableCancelCallback?
    var onError: StartableErrorCallback?
    var onApprove: StartableApproveCallback?
    var onShippingChange: StartableShippingCallback?

    required init(nxoConfig: CheckoutConfig) { }

    // todo: implemenet cases for other callbacks
    func start(
        presentingViewController: UIViewController?,
        orderID: String,
        onStartableApprove: @escaping StartableApproveCallback,
        onStartableShippingChange: @escaping StartableShippingCallback,
        onStartableCancel: @escaping StartableCancelCallback,
        onStartableError: @escaping StartableErrorCallback,
        nxoConfig: CheckoutConfig
    ) {
        self.onCancel = onStartableCancel
        self.onError = onStartableError
        self.onApprove = onStartableApprove
        self.onShippingChange = onStartableShippingChange
        self.userAuthenticationEmail = nxoConfig.authConfig.userEmail
    }

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
        actions: PayPalNativePaysheetActions,
        address: PayPalNativeShippingAddress,
        method: PayPalNativeShippingMethod? = nil
    ) {
        onShippingChange?(type, actions, address, method)
    }
}
