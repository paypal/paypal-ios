import UIKit

/// Edges for the smart payment button, these affect the corner radius.
public enum PaymentButtonEdges: Int {

    /// Hard edges on button with 0 corner radius.
    case sharp

    /// Soft edges with a corner radius of 4 pts.
    case rounded

    /// Pill shaped corner radius.
    case pill

    func cornerRadius(for view: UIView) -> CGFloat {
        switch self {
        case .sharp:
            return 0.0

        case .rounded:
            return 4.0

        case .pill:
            return view.frame.size.height / 2
        }
    }
    public var description: String {
        switch self {
        case .sharp:
            return "sharp"

        case .rounded:
            return "rounded"

        case .pill:
            return "pill"
        }
    }
}
