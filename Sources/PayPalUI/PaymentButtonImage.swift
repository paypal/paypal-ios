import UIKit

enum PaymentButtonImage {
    case payPal, payPalCredit

    var rawValue: UIImage? {
        switch self {
        case .payPal:
            return UIImage(named: "PayPalLogo", in: PaymentButton.bundle, compatibleWith: nil)
        case .payPalCredit:
            return UIImage(named: "PayPalCreditLogo", in: PaymentButton.bundle, compatibleWith: nil)
        }
    }
}
