import UIKit

/// The size category which determines how the button is shown.
public enum PaymentButtonSize: Int, CustomStringConvertible {

    /// Smallest button size that will show the PayPal monogram only. Use this for screens where space is limited. The recommended size when displaying on screens with limited space `.miniWithWordmark`
    case mini

    /// Smallest button size that will show the primary mark (PayPal monogram and wordmark). This is the recommended size when displaying on screens with limited space.
    case miniWithWordmark

    /// Collapsed shows the primary mark (PayPal monogram and wordmark) along with the prefix or suffix.
    case collapsed

    /// Expanded shows the primary mark (PayPal monogram and wordmark along with the prefix or suffix
    case expanded

    /// Full will show the primary mark (PayPal monogram and wordmark along with the prefix or suffix.
    case full

    var font: UIFont {
        switch self {
        case .mini, .miniWithWordmark, .collapsed:
            return PaymentButtonFont.secondaryFont

        case .expanded:
            return PaymentButtonFont.primaryFont

        case .full:
            return PaymentButtonFont.systemFont18
        }
    }

    var elementSpacing: CGFloat {
        switch self {
        case .mini, .miniWithWordmark, .collapsed:
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

        case .miniWithWordmark:
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

        case .miniWithWordmark:
            return "mini with wordmark"

        case .collapsed:
            return "collapsed"

        case .expanded:
            return "expanded"

        case .full:
            return "full"
        }
    }
}
