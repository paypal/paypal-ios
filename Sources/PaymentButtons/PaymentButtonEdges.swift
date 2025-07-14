import UIKit

/// Edges for the smart payment button, these affect the corner radius.
public enum PaymentButtonEdges: Equatable {

    /// Hard edges on button with 0 corner radius.
    case sharp

    /// Soft edges with a corner radius of 4 pts.
    case soft

    /// Pill shaped corner radius.
    case pill

    /// Custom corner radius.
    case custom(CGFloat)

    func cornerRadius(for button: PaymentButton) -> CGFloat {
        switch self {
        case .sharp:
            return 0.0

        case .soft:
            return 4.0

        case .pill:
            return button.buttonHeight / 2

        case .custom(let cornerRadius):
            return min(cornerRadius, button.buttonHeight / 2)
        }
    }
    public var description: String {
        switch self {
        case .sharp:
            return "sharp"

        case .soft:
            return "soft"

        case .pill:
            return "pill"

        case .custom:
            return "custom"
        }
    }
}
