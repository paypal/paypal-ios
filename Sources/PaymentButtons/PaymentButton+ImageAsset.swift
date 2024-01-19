import UIKit

extension PaymentButton {

    // MARK: - Internal Properties
    
    var image: UIImage? {
        UIImage(named: fileName, in: PaymentButton.bundle, compatibleWith: nil)
    }
    
    var imageAccessibilityLabel: String {
        // NEXT_MAJOR_VERSION: - To be replaced with translation strings.
        fileName.starts(with: "credit") ? "PayPal Credit" : "PayPal"
    }
    
    // MARK: - Private Properties
    
    /// Name of the sized `.imageset` assets within `Assets.xcassets` directory
    private var fileName: String {
        var imageAssetString = ""
        switch fundingSource {
        case .payPal:
            imageAssetString += "paypal_"

            if size == .mini {
                imageAssetString += "monogram_"
            }

        case .payLater:
            imageAssetString += "paypal_monogram_"

        case .credit:
            imageAssetString += "credit_"
        }
        imageAssetString += "color"
        
        return imageAssetString
    }
}
