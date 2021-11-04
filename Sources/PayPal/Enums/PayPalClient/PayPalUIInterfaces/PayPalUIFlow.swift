//
//  PayPalUIFlow.swift
//  PayPalUIFlow
//
//  Created by Jones, Jon on 11/4/21.
//

import Foundation
import PayPalCheckout
import UIKit

protocol PayPalUIFlow {
    associatedtype ApprovalType: PayPalCheckoutApproval
    associatedtype PayPalErrorType: PayPalCheckoutErrorInfo

    typealias ApprovalCallback = (ApprovalType) -> Void
    typealias CancelCallback = () -> Void
    typealias ErrorCallback = (PayPalErrorType) -> Void

    static func set(config: CheckoutConfig)

    // swiftlint:disable function_parameter_count
    static func start(
        presentingViewController: UIViewController?,
        createOrder: CheckoutConfig.CreateOrderCallback?,
        onApprove: ApprovalCallback?,
        onShippingChange: CheckoutConfig.ShippingChangeCallback?,
        onCancel: CancelCallback?,
        onError: ErrorCallback?
    )
}

extension Checkout: PayPalUIFlow { }
