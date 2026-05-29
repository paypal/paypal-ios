import UIKit
import SwiftUI

/// Configuration for Venmo button
public final class VenmoButton: PaymentButton {

    /// Available colors for VenmoButton.
    public enum Color: String {
        case blue
        case white
        case black

        var color: PaymentButtonColor {
            switch self {
            case .blue:
                return .venmoBlue
            case .white:
                return .white
            case .black:
                return .black
            }
        }
    }

    /// Available labels for VenmoButton.
    public enum Label: String {
        /// Display no label
        case none

        /// Display "Pay with" on the left side of the button's logo
        case payWith = "Pay with"

        var label: PaymentButtonLabel? {
            PaymentButtonLabel(rawValue: rawValue)
        }
    }

    /// Initialize a VenmoButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to blue if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    ///   - label: Label displayed next to the button's logo. Default to no label.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .blue,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        label: Label? = nil
    ) {
        self.init(
            fundingSource: .venmo,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: label?.label
        )
    }

    deinit {}
}

public extension VenmoButton {

    /// VenmoButton for SwiftUI
    struct Representable: UIViewRepresentable {

        private var action: () -> Void = { }

        private let button: VenmoButton

        /// Initialize a VenmoButton
        /// - Parameters:
        ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
        ///   - color: Color of the button. Default to blue if not provided.
        ///   - edges: Edges of the button. Default to softEdges if not provided.
        ///   - size: Size of the button. Default to collapsed if not provided.
        ///   - label: Label displayed next to the button's logo. Default to no label.
        public init(
            insets: NSDirectionalEdgeInsets? = nil,
            color: VenmoButton.Color = .blue,
            edges: PaymentButtonEdges = .softEdges,
            size: PaymentButtonSize = .collapsed,
            label: VenmoButton.Label? = nil,
            _ action: @escaping () -> Void = { }
        ) {
            button = VenmoButton(
                fundingSource: .venmo,
                color: color.color,
                edges: edges,
                size: size,
                insets: insets,
                label: label?.label
            )
            self.action = action
        }

        // MARK: - UIViewRepresentable methods

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

// MARK: VenmoButton Preview

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
