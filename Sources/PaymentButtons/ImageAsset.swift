import UIKit

enum ImageAsset {
    static func paymentButtonLogo(for button: PaymentButton) -> UIImage? {
        var imageAssetString = ""
        switch button.fundingSource {
        case .payPal:
            imageAssetString += "paypal_"

            if button.size == .mini {
                imageAssetString += "monogram_"
            }

        case .payLater:
            imageAssetString += "paypal_monogram_"

        case .credit:
            imageAssetString += "credit_"
        }

        imageAssetString += "color"

        return UIImage(named: imageAssetString, in: PaymentButton.bundle, compatibleWith: nil)
    }
}
