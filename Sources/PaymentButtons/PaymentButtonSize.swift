import UIKit

/// The size category which determines how the button is shown.
public enum PaymentButtonSize: Int, CustomStringConvertible {

    /// Smallest button size uses the primary mark, vertically stacked. This is the recommended size when displaying on screens with limited space.
    case mini

    /// Regular size shows the primary mark along with the prefix or suffix
    case regular

    var font: UIFont {
        switch self {
        case .mini:
            return PaymentButtonFont.secondaryFont

        case .regular:
            return PaymentButtonFont.primaryFont
        }
    }

    var elementSpacing: CGFloat {
        switch self {
        case .mini:
            return 4.0

        case .regular:
            return 4.5
        }
    }

    var elementConstraints: CGSize {
        switch self {
        case .mini:
            return CGSize(width: 36, height: 24)
            
        case .regular:
            return CGSize(width: 0, height: 0)
        }
    }

    var elementPadding: NSDirectionalEdgeInsets {
        switch self {

        case .mini:
            return NSDirectionalEdgeInsets(
                top: 5.0,
                leading: 12.0,
                bottom: 5.0,
                trailing: 12.0
            )

        case .regular:
            return NSDirectionalEdgeInsets(
                top: 10.0,
                leading: 80.0,
                bottom: 10.0,
                trailing: 80.0
            )
        }
    }

    public var description: String {
        switch self {
        case .mini:
            return "mini"

        case .regular:
            return "regular"
        }
    }
}
