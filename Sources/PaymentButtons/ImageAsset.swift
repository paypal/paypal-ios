import UIKit

enum ImageAsset {
    static func paymentButtonLogo(for button: PaymentButton) -> UIImage? {
        var imageAssetString = ""
        switch button.fundingSource {
        case .payPal:
            imageAssetString += "paypal"

        case .payLater:
            imageAssetString += "paypal"

            if button.size == .collapsed {
                imageAssetString += "_monogram"
            }

        case .credit:
            imageAssetString += "paypal"

            if button.size == .collapsed {
                imageAssetString += "_monogram_credit"
            }
            else if button.size != .miniWithWordmark && button.size != .mini {
                imageAssetString += "_credit"
            }
        }

        if button.size == .mini {
            imageAssetString += "_monogram"
        }
        else if button.size == .miniWithWordmark {
            imageAssetString += "_vertical"
        }

        return UIImage(named: imageAssetString, in: PaymentButton.bundle, compatibleWith: nil)
    }
}
