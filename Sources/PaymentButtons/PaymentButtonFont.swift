import UIKit

enum PaymentButtonFont {
    /// The primary font
    public static let paypalPrimaryFont = UIFont(name: "PayPalOpen-Regular", size: 14) ??
        .systemFont(ofSize: UIFont.systemFontSize)
}

extension UIFont {
    private static func registerFont(withName name: String, fileExtension: String) {
        let frameworkBundle = Bundle(for: PaymentButton.self)
        guard
            let pathForResourceString = frameworkBundle.path(forResource: name, ofType: fileExtension),
            let fontData = NSData(contentsOfFile: pathForResourceString),
            let dataProvider = CGDataProvider(data: fontData),
            let fontRef = CGFont(dataProvider) else { return }
        print("Font file path:", pathForResourceString)

        var errorRef: Unmanaged<CFError>? = nil

        if (CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false) {
            print("Error registering font")
        }
    }

    static func registerFont() {
        registerFont(withName: "PayPalOpen-Regular", fileExtension: "otf")
    }
}
