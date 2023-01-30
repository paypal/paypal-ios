import UIKit

enum PaymentButtonImage {
    case payPal, payPalCredit, payPalPayLater

    var rawValue: UIImage? {
        switch self {
        case .payPal:
            return UIImage(named: "PayPalLogo", in: PaymentButton.bundle, compatibleWith: nil)
        case .payPalCredit:
            return UIImage(named: "PayPalCreditLogo", in: PaymentButton.bundle, compatibleWith: nil)
        case .payPalPayLater:
            return UIImage(named: "PayPalPayLaterLogo", in: PaymentButton.bundle, compatibleWith: nil)
        }
    }
}
