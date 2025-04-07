import UIKit
import SwiftUI

/// Configuration for Card button
public final class CardButton: PaymentButton {

    /// Available colors for CardButton.
    public enum Color: String {
        case white
        case black

        var color: PaymentButtonColor {
            PaymentButtonColor(rawValue: rawValue) ?? .black
        }
    }

    /// Available labels for CardButton.
    public enum Label: String {
        /// Display "Debit or Credit Card" on the left side of the button's logo
        case card = "Debit or Credit Card"

        var label: PaymentButtonLabel? {
            PaymentButtonLabel(rawValue: rawValue)
        }
    }

    /// Initialize a PayPalButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to black if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    ///   - label: Label displayed next to the button's logo. Default to no label.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .black,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        label: Label = .card,
        cardImage: UIImage? = nil
    ) {
        self.init(
            fundingSource: .card,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: label.label
        )
    }

    deinit {}
}

public extension CardButton {

    /// CardlButton for SwiftUI
    struct Representable: UIViewRepresentable {

        private var action: () -> Void = { }

        private let button: CardButton

        /// Initialize a CardButton
        /// - Parameters:
        ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
        ///   - color: Color of the button. Default to gold if not provided.
        ///   - edges: Edges of the button. Default to softEdges if not provided.
        ///   - size: Size of the button. Default to expanded if not provided.
        ///   - label: Label displayed next to the button's logo. Default to no label.
        public init(
            insets: NSDirectionalEdgeInsets? = nil,
            color: CardButton.Color = .black,
            edges: PaymentButtonEdges = .softEdges,
            size: PaymentButtonSize = .expanded,
            label: CardButton.Label = .card,
            _ action: @escaping () -> Void = { }
        ) {
            button = CardButton(
                fundingSource: .card,
                color: color.color,
                edges: edges,
                size: size,
                insets: insets,
                label: label.label
            )
            self.action = action
        }

        // MARK: - UIViewRepresentable methods
        // TODO: Make unit test for UIVRepresentable methods: https://engineering.paypalcorp.com/jira/browse/DTNOR-623

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

// MARK: PayPalButton Preview

struct CardButtonView: View {

    var body: some View {
        CardButton.Representable()
    }
}

struct CardButtonView_Preview: PreviewProvider {

    static var previews: some View {
        CardButtonView()
    }
}
