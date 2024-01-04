import UIKit

enum ImageAsset {
    static func paymentButtonLogo(for button: PaymentButton) -> UIImage? {
        var imageAssetString = ""
        switch button.fundingSource {
        case .payPal:
            imageAssetString = "paypal"

        case .payLater:
            imageAssetString = "paypal"

            if button.size == .collapsed {
                imageAssetString = "paypal_monogram"
            }

        case .credit:
            if button.size == .collapsed {
                imageAssetString = "credit_monogram"
            }
            else if button.size != .miniWithWordmark && button.size != .mini {
                imageAssetString = "credit"
            }
        }

        if button.size == .mini {
            imageAssetString = "paypal_monogram"
        }
        else if button.size == .miniWithWordmark {
            imageAssetString = "paypal_vertical"
        }

        return UIImage(named: imageAssetString, in: PaymentButton.bundle, compatibleWith: nil)
    }
}
