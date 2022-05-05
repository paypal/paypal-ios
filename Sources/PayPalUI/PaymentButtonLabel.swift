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

  //TODO: check in NXO
  var stringValue: String {
    switch self {
    case .checkout:
      return "PAYMENT_BUTTON_CHECKOUT_LABEL"

    case .buyNow:
      return "PAYMENT_BUTTON_BUY_NOW_LABEL"

    case .payWith:
      return "PAYMENT_BUTTON_PAY_WITH_LABEL"

    case .payLater:
      return "PAYMENT_BUTTON_PAY_LATER_LABEL"

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
