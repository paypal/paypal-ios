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

    var elementPadding: NSDirectionalEdgeInsets {
        switch self {

        case .mini:
            return NSDirectionalEdgeInsets(
                top: 9.0,
                leading: 20.0,
                bottom: 9.0,
                trailing: 20.0
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
