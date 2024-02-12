import UIKit

enum ImageAsset {
    static func paymentButtonLogo(for button: PaymentButton) -> UIImage? {
        var imageAssetString = ""
        switch button.fundingSource {
        case .payPal:
            imageAssetString = "paypal"

        case .payLater:
            imageAssetString = "paypal"
            
        case .credit:
            if button.size != .mini {
                imageAssetString = "credit"
            }
        }
            if button.size == .mini {
                imageAssetString = "paypal_vertical"
            }

        return UIImage(named: imageAssetString, in: PaymentButton.bundle, compatibleWith: nil)
    }
}
