import Foundation
import UIKit
import PayPalCheckout
#if canImport(CorePayments)
import CorePayments
#endif

class NativeCheckoutProvider: NativeCheckoutStartable {

    /// Used in POST body for FPTI analytics.
    var correlationID: String?

    private let checkout: CheckoutProtocol.Type
    
    init(_ mxo: CheckoutProtocol.Type = Checkout.self) {
        self.checkout = mxo
    }

    // swiftlint:disable:next function_parameter_count
    func start(
        presentingViewController: UIViewController?,
        orderID: String,
        onStartableApprove: @escaping StartableApproveCallback,
        onStartableShippingChange: @escaping StartableShippingCallback,
        onStartableCancel: @escaping StartableCancelCallback,
        onStartableError: @escaping StartableErrorCallback,
        nxoConfig: CheckoutConfig
    ) {
        checkout.showsExitAlert = false
        checkout.set(config: nxoConfig)
        guaranteeMainThread {
            self.checkout.start(
                presentingViewController: presentingViewController,
                createOrder: { createOrderAction in
                    createOrderAction.set(orderId: orderID)
                },
                onApprove: { approval in
                    self.correlationID = approval.data.correlationIDs.riskCorrelationID
                    onStartableApprove(approval.data.ecToken, approval.data.payerID)
                },
                onShippingChange: { shippingChangeData, shippingChangeActions in
                    let type = shippingChangeData.type
                    let shippingActions = PayPalNativePaysheetActions(shippingChangeActions)
                    let shippingAddress = PayPalNativeShippingAddress(shippingChangeData.selectedShippingAddress)
                    var shippingMethod: PayPalNativeShippingMethod?
                    if let selectedMethod = shippingChangeData.selectedShippingMethod {
                        shippingMethod = PayPalNativeShippingMethod(selectedMethod)
                    }
                    onStartableShippingChange(type, shippingActions, shippingAddress, shippingMethod)
                },
                onCancel: { onStartableCancel() },
                onError: { error in
                    self.correlationID = error.correlationIDs.riskCorrelationID
                    onStartableError(error.reason)
                }
            )
        }
    }
    
    private func guaranteeMainThread(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
}

protocol CheckoutProtocol {
    
    // swiftlint:disable:next function_parameter_count
    static func start(
        presentingViewController: UIViewController?,
        createOrder: PayPalCheckout.CheckoutConfig.CreateOrderCallback?,
        onApprove: PayPalCheckout.CheckoutConfig.ApprovalCallback?,
        onShippingChange: PayPalCheckout.CheckoutConfig.ShippingChangeCallback?,
        onCancel: PayPalCheckout.CheckoutConfig.CancelCallback?,
        onError: PayPalCheckout.CheckoutConfig.ErrorCallback?
    )
    
    static var showsExitAlert: Bool { get set }
    
    static func set(config: PayPalCheckout.CheckoutConfig)
}

extension Checkout: CheckoutProtocol { }
