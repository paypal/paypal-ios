import UIKit

enum ButtonType {
    case payPal
    case payPalCredit
}

struct PaymentButtons {

    // asset identfier path for image and color button assets
    private let bundleIdentifier = Bundle(identifier: "com.paypal.ios-sdk.PayPal")

    func getButtonColor(for buttonType: ButtonType) -> UIColor? {
        switch buttonType {
        case .payPal:
            return UIColor(named: "PayPalGold", in: bundleIdentifier, compatibleWith: nil)
        case .payPalCredit:
            return UIColor(named: "PayPalDarkBlue", in: bundleIdentifier, compatibleWith: nil)
        }
    }
    
    func getButtonLogo(for buttonType: ButtonType) -> UIImage? {
        switch buttonType {
        case .payPal:
            return UIImage(named: "PayPalLogo", in: bundleIdentifier, compatibleWith: nil)
        case .payPalCredit:
            return UIImage(named: "PayPalCreditLogo", in: bundleIdentifier, compatibleWith: nil)
        }
    }
}
