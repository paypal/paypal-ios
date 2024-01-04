import UIKit

class ImageAsset {

    // MARK: - Internal Properties
    
    var image: UIImage? {
        UIImage(named: fileName, in: PaymentButton.bundle, compatibleWith: nil)
    }
    
    var accessibilityLabel: String {
        // NEXT_MAJOR_VERSION: - To be replaced with translation strings.
        if fileName.starts(with: "credit") {
            return "PayPal Credit"
        } else {
            return "PayPal"
        }
    }
    
    // MARK: - Private Properties
    
    /// Name of the sized `.imageset` assets within `Assets.xcassets` directory
    private var fileName: String {
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
        
        return imageAssetString
    }
    
    private let button: PaymentButton
    
    // MARK: - Initializer
        
    init(button: PaymentButton) {
        self.button = button
    }
}
