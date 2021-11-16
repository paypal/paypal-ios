import UIKit

enum PayPalButtonType {
    case payPal
    case payPalCredit
}

// Handles functionality shared across payment buttons
public class PaymentButton: UIButton {

    // asset identfier path for image and color button assets
    private let bundleIdentifier = Bundle(identifier: "com.paypal.ios-sdk.PayPal")

    // MARK: - Internal Helper Functions

    func getButtonColor(for buttonType: PayPalButtonType) -> UIColor? {
        switch buttonType {
        case .payPal:
            return UIColor(named: "PayPalGold", in: bundleIdentifier, compatibleWith: nil)
        case .payPalCredit:
            return UIColor(named: "PayPalDarkBlue", in: bundleIdentifier, compatibleWith: nil)
        }
    }

    func getButtonLogo(for buttonType: PayPalButtonType) -> UIImage? {
        switch buttonType {
        case .payPal:
            return UIImage(named: "PayPalLogo", in: bundleIdentifier, compatibleWith: nil)
        case .payPalCredit:
            return UIImage(named: "PayPalCreditLogo", in: bundleIdentifier, compatibleWith: nil)
        }
    }

    func setLogoImageSize() -> UIEdgeInsets {
        let buttonSize = frame.size
        return UIEdgeInsets(
            top: buttonSize.height / 4,
            left: buttonSize.width / 4,
            bottom: buttonSize.height / 4,
            right: buttonSize.width / 4
        )
    }

    // MARK: - Override Function

    // Once we layout our subviews, we need to update the logo with the button frame
    public override func layoutSubviews() {
        super.layoutSubviews()
        imageView?.contentMode = .scaleAspectFit
        imageEdgeInsets = setLogoImageSize()
    }
}
