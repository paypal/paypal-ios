//
//  PaymentButtonLabel.swift
//  PayPalUI
//
//  Created by Jose Noriega on 02/05/2022.
//

import Foundation

/// The label displayed next to PaymentButton's logo.
@objc(PPCPaymentButtonLabel)
public enum PaymentButtonLabel: Int {

    /// Add "Checkout" to the right of button's logo
    case checkout = 0

    /// Add "Buy Now" to the right of button's logo
    case buyNow = 1

    /// Add "Pay with" to the left of button's logo
    case payWith = 2

    /// Add "Pay later" to the right of button's logo, only used for PayPalPayLaterButton
    case payLater = 3

    enum Position {
        case prefix
        case suffix
    }

    var stringValue: String {
        switch self {
        case .checkout:
            return "Checkout"
        case .buyNow:
            return "Buy Now"
        case .payWith:
            return "Pay with"
        case .payLater:
            return "Pay Later"
        }
    }

    var position: Position {
        switch self {
        case .checkout, .buyNow, .payLater:
            return .suffix

        case .payWith:
            return .prefix
        }
    }
}
