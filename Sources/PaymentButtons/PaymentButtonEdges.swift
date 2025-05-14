import UIKit

/// Edges for the smart payment button, these affect the corner radius.
public enum PaymentButtonEdges: Equatable {

    /// Hard edges on button with 0 corner radius.
    case hardEdges

    /// Soft edges with a corner radius of 4 pts.
    case softEdges

    /// Pill shaped corner radius.
    case rounded

    /// Custom corner radius.
    case custom(CGFloat)

    func cornerRadius(for button: PaymentButton) -> CGFloat {
        switch self {
        case .hardEdges:
            return 0.0

        case .softEdges:
            return 4.0

        case .rounded:
            return button.buttonHeight / 2

        case .custom(let cornerRadius):
            return min(cornerRadius, button.buttonHeight / 2)
        }
    }
    public var description: String {
        switch self {
        case .hardEdges:
            return "hardEdges"

        case .softEdges:
            return "softEdges"

        case .rounded:
            return "rounded"

        case .custom:
            return "custom"
        }
    }
}
