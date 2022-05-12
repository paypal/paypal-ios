import Foundation

/// The funding source to be used when checkout with PaymentButton
public enum PaymentButtonFundingSource: String {
    case payPal = "PayPal"
    case payLater = "Pay Later"
    case credit = "Credit"
}
