import Foundation

/// The label displayed next to PaymentButton's logo.
public enum PaymentButtonLabel: String {

    /// Add "Checkout" to the right of button's logo
    case checkout = "Checkout"

    /// Add "Buy Now" to the right of button's logo
    case buyNow = "Buy Now"

    /// Add "Pay with" to the left of button's logo
    case payWith = "Pay with"

    /// Add "Pay later" to the right of button's logo, only used for PayPalPayLaterButton
    case payLater = "Pay Later"

    /// Add "Debit or Credit Card" to the right of button's logo, only used for CardButton
    case card = "Debit or Credit Card"

    enum Position {
        case prefix
        case suffix
    }

    var position: Position {
        switch self {
        case .card, .checkout, .buyNow, .payLater:
            return .suffix

        case .payWith:
            return .prefix
        }
    }
}
