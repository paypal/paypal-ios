import UIKit

enum PaymentButtonFont {
    /// The primary font
    public static let paypalPrimaryFont = UIFont(name: "PayPalPro-Book", size: 14) ??
        .systemFont(ofSize: UIFont.systemFontSize)
    public static func paypalScaledFont(for height: CGFloat) -> UIFont {
        let pointSize = height * 0.44
        return UIFont(name: "PayPalPro-Book", size: pointSize) ?? .systemFont(ofSize: pointSize)
    }
}

extension UIFont {

    private static func registerFont(withName name: String, fileExtension: String) {
        var errorRef: Unmanaged<CFError>?
        let frameworkBundle = Bundle(for: PaymentButton.self)

        guard UIFont(name: name, size: 10.0) == nil else {
            return
        }

        guard
            let pathForResourceString = frameworkBundle.path(forResource: name, ofType: fileExtension),
            let fontData = NSData(contentsOfFile: pathForResourceString),
            let dataProvider = CGDataProvider(data: fontData),
            let fontRef = CGFont(dataProvider) else { return }
        print("Font file path:", pathForResourceString)

        if !CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) {
            print("Error registering font")
        }
    }

    static func registerFont() {
        registerFont(withName: "PayPalPro-Book", fileExtension: "otf")
    }
}
