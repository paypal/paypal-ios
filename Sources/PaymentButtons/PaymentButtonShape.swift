import UIKit

/// Edges for the smart payment button, these affect the corner radius.
public enum PaymentButtonShape: Equatable {

    /// Sharp corners with 0 corner radius.
    case rectangle

    /// Rounded with a corner radius of 4 pts.
    case rounded

    /// Pill shaped corner radius.
    case pill

    /// Custom corner radius.
    case custom(CGFloat)

    func cornerRadius(for view: UIView) -> CGFloat {
        switch self {
        case .rectangle:
            return 0.0

        case .rounded:
            return 4.0

        case .pill:
            return view.frame.size.height / 2

        case .custom(let cornerRadius):
            return min(cornerRadius, view.frame.size.height / 2)
        }
    }
    public var description: String {
        switch self {
        case .rectangle:
            return "hardEdges"

        case .rounded:
            return "rounded"

        case .pill:
            return "pill"

        case .custom:
            return "custom"
        }
    }
}
