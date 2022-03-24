import UIKit

enum PaymentButtonColor {
    case gold, darkBlue

    var rawValue: UIColor? {
        switch self {
        case .gold:
            return UIColor(named: "PayPalGold", in: PaymentButton.bundle, compatibleWith: nil)
        case .darkBlue:
            return UIColor(named: "PayPalDarkBlue", in: PaymentButton.bundle, compatibleWith: nil)
        }
    }
}
