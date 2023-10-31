import UIKit

@MainActor
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

        switch button.color {
        case .gold, .white, .silver:
            imageAssetString += "color"

        case .black, .darkBlue:
            imageAssetString += "monochrome"

        case .blue:
            imageAssetString += "blue"
        }

        return UIImage(named: imageAssetString, in: PaymentButton.bundle, compatibleWith: nil)
    }
}
