import UIKit

enum PaymentButtonFont {
    /// The primary font
    public static let paypalPrimaryFont = UIFont(name: "PayPalOpen-Regular", size: 14) ??
        .systemFont(ofSize: UIFont.systemFontSize)
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
        registerFont(withName: "PayPalOpen-Regular", fileExtension: "otf")
    }
}
