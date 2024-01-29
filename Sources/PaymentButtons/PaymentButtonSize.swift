import UIKit

/// The size category which determines how the button is shown.
public enum PaymentButtonSize: Int, CustomStringConvertible {

    /// Smallest button size uses the primary mark, vertically stacked. This is the recommended size when displaying on screens with limited space.
    case mini

    /// Standard size shows the primary mark along with the prefix or suffix
    case standard

    var font: UIFont {
        PaymentButtonFont.paypalPrimaryFont
    }

    var elementSpacing: CGFloat {
        switch self {
        case .mini:
            return 4.0

        case .standard:
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

        case .standard:
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

        case .standard:
            return "standard"
        }
    }
}
