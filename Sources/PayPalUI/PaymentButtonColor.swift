import UIKit

/// The smart payment button type, this will adjust our images, colors, sizes, etc.
@objc(PPCPaymentButtonColor)
public enum PaymentButtonColor: Int, CaseIterable, CustomStringConvertible {

    /// The gold background and blue wordmark, monogram, and black text.
    case gold = 0

    /// The white background and blue wordmark, monogram, and black text.
    case white = 1

    /// The black background and monochrome wordmark, monogram, and white text.
    case black = 2

    /// The silver background and blue wordmark, monogram, and black text.
    case silver = 3

    /// The blue background and white wordmark, blue monogram, and white text.
    case blue = 4

    /// The dark blue background with PayPal Credit wordmark and monogram.
    case darkBlue = 5

    var color: UIColor {
        switch self {
        case .gold:
            return UIColor(hexString: "#FFC439")

        case .white:
            return UIColor(hexString: "#FFFFFF")

        case .black:
            return UIColor(hexString: "#000000")

        case .silver:
            return UIColor(hexString: "#EEEEEE")

        case .blue:
            return UIColor(hexString: "#0070BA")

        case .darkBlue:
            return UIColor(hexString: "#073990")
        }
    }

    var fontColor: UIColor {
        switch self {
        case .gold, .white, .silver:
            return .black

        case .blue, .black, .darkBlue:
            return .white
        }
    }

    public var description: String {
        switch self {
        case .gold:
            return "Gold"

        case .white:
            return "White"

        case .black:
            return "Black"

        case .silver:
            return "Silver"

        case .blue:
            return "Blue"

        case .darkBlue:
            return "Dark blue"
        }
    }
}

extension UIColor {

    /**
    Creates an UIColor from HEX String in "#482937" format
     
    - Parameters:
    - hexString: HEX String in "#482937" format
     
    - Returns: UIColor from HexString
    */
    convenience init(hexString: String) {
        let hexString: String = (hexString as NSString).trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString as String)

        if hexString.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let mask = 0x000000FF
        let redAux = Int(color >> 16) & mask
        let greenAux = Int(color >> 8) & mask
        let blueAux = Int(color) & mask
        let red = CGFloat(redAux) / 255.0
        let green = CGFloat(greenAux) / 255.0
        let blue = CGFloat(blueAux) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
