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
            imageAssetString += "paypal-logo-"

        switch color {
        case .white, .blue:
            imageAssetString += "black"

        case .black:
            imageAssetString += "white"
        }
        
        return imageAssetString
    }
}
