import UIKit

/// The size category which determines how the button is shown.
public enum PaymentButtonSize: Int, CustomStringConvertible {

    /// Circle shaped button similar to a floating action button will show the monogram, if `.venmo` then will show `Venmo` logo.
    case mini

    /// Collapsed will only show the wordmark.
    case collapsed

    /// Expanded shows the wordmark along with the suffix.
    case expanded

    /// Full will show the wordmark along with the prefix and suffix.
    case full

    var font: UIFont {
        PaymentButtonFont.paypalPrimaryFont
    }

    var elementSpacing: CGFloat {
        switch self {
        case .mini, .collapsed:
            return 4.0

        case .expanded:
            return 4.5

        case .full:
            return 6.0
        }
    }

    var elementPadding: NSDirectionalEdgeInsets {
        switch self {
        case .mini:
            return NSDirectionalEdgeInsets(
                top: 14.0,
                leading: 14.0,
                bottom: 14.0,
                trailing: 14.0
            )

        case .collapsed:
            return NSDirectionalEdgeInsets(
                top: 15.0,
                leading: 20.0,
                bottom: 15.0,
                trailing: 20.0
            )

        case .expanded:
            return NSDirectionalEdgeInsets(
                top: 13.0,
                leading: 24.0,
                bottom: 13.0,
                trailing: 24.0
            )

        case .full:
            return NSDirectionalEdgeInsets(
                top: 15.0,
                leading: 44.0,
                bottom: 15.0,
                trailing: 44.0
            )
        }
    }

    public var description: String {
        switch self {
        case .mini:
            return "mini"

        case .collapsed:
            return "collapsed"

        case .expanded:
            return "expanded"

        case .full:
            return "full"
        }
    }
}
