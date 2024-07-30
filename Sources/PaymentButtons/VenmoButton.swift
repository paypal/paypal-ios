import UIKit
import SwiftUI

/// Configuration for the Venmo button
public final class VenmoButton: PaymentButton {
    
    /// Available colors for VenmoButton
    public enum Color: String {
        case primaryBlue
        
        var color: PaymentButtonColor {
            PaymentButtonColor(rawValue: rawValue) ?? .primaryBlue
        }
    }
    
    /// Available button states for VenmoButton.
    public enum ButtonState: String {
        /// default button state
        case _default
        
        /// hover button state
        case hover
        
        /// focus button state
        case focus
        
        /// active button state
        case active
        
        var color: UIColor {
            switch self {
            case ._default:
                return UIColor(hexString: "#008CFF")
            case .hover:
                return UIColor(hexString: "#0080EA")
            case .focus:
                return UIColor(hexString: "#0080EA")
            case .active:
                return UIColor(hexString: "#006DC7")
            }
        }
    }
    
    /// Initialize a VenmoButton
    /// - Parameters:
    ///    - insets: Edge insets of the button that determine the spacing of the button's edges relative to its content
    ///    - color: Color of the button. Default to primary blue if not provided.
    ///    - edges: Edges of the button. Default to softEdges if not provided.
    ///    - size: Size of the button. Default to collapsed if not provided.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .primaryBlue,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed
    ) {
        self.init(
            fundingSource: .venmo,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: nil
        )
    }
    
    deinit {}
}

public extension VenmoButton {
    
    /// VenmoButton for SwiftUI
    struct Representable: UIViewRepresentable {
        
        private let button: VenmoButton
        private var action: () -> Void = { }
        
        /// Initialize a VenmoButton
        /// - Parameters:
        ///    - insets: Edge insets of the button that determine the spacing of the button's edges relative to its content
        ///    - color: Color of the button. Default to primary blue if not provided.
        ///    - edges: Edges of the button. Default to softEdges if not provided.
        ///    - size: Size of the button. Default to collapsed if not provided.
        public init(
            insets: NSDirectionalEdgeInsets? = nil,
            color: VenmoButton.Color = .primaryBlue,
            edges: PaymentButtonEdges = .softEdges,
            size: PaymentButtonSize = .collapsed,
            _ action: @escaping () -> Void = { }
        ) {
            self.button = VenmoButton(
                fundingSource: .venmo,
                color: color.color,
                edges: edges,
                size: size,
                insets: insets,
                label: nil
            )
            self.action = action
        }
        
        // MARK: - UIViewRepresentable Methods
        
        public func makeCoordinator() -> Coordinator {
            Coordinator(action: action)
        }
        
        public func makeUIView(context: Context) -> PaymentButton {
            button.addTarget(context.coordinator, action: #selector(Coordinator.onAction(_:)), for: .touchUpInside)
            return button
        }
        
        public func updateUIView(_ uiView: PaymentButton, context: Context) {
            context.coordinator.action = action
        }
    }
}

// MARK: - VenmoButton Preview

struct VenmoButtonView: View {
    
    var body: some View {
        VenmoButton.Representable()
    }
}

struct VenmoButtonView_Preview: PreviewProvider {
    
    static var previews: some View {
        VenmoButtonView()
    }
}
