import UIKit

/// Edges for the smart payment button, these affect the corner radius.
public enum PaymentButtonEdges: Int {

    /// Hard edges on button with 0 corner radius.
    case hardEdges

    /// Soft edges with a corner radius of 4 pts.
    case softEdges

    /// Pill shaped corner radius.
    case rounded

    func cornerRadius(for view: UIView) -> CGFloat {
        switch self {
        case .hardEdges:
            return 0.0

        case .softEdges:
            return 4.0

        case .rounded:
            return view.frame.size.height / 2
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
        }
    }
}
