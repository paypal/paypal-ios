import UIKit
import SwiftUI

/// Configuration for PayPal button
public final class PayPalButton: PaymentButton {

    /// Available colors for PayPalButton.
    public enum Color: String {
        case gold
        case white
        case black
        case silver
        case blue

        var color: PaymentButtonColor {
            PaymentButtonColor(rawValue: rawValue) ?? .gold
        }
    }

    /// Available labels for PayPalButton.
    public enum Label: String {
        /// Display no label
        case none
        
        /// Display "Checkout" on the right side of the button's logo
        case checkout = "Checkout"

        /// Display "Buy now" on the right side of the button's logo
        case buyNow = "Buy Now"

        /// Display "Pay with" on the left side of the button's logo
        case payWith = "Pay with"

        var label: PaymentButtonLabel? {
            PaymentButtonLabel(rawValue: rawValue)
        }
    }

    /// Initialize a PayPalButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to gold if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    ///   - label: Label displayed next to the button's logo. Default to no label.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .gold,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        label: Label? = nil
    ) {
        self.init(
            fundingSource: .payPal,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: label?.label
        )
    }

    deinit {}
}

public extension PayPalButton {
    
    /// PayPalButton for SwiftUI
    struct Representable: UIViewRepresentable {
        
        private var action: () -> Void = { }
    
        private let button: PayPalButton
        
        /// Initialize a PayPalButton
        /// - Parameters:
        ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
        ///   - color: Color of the button. Default to gold if not provided.
        ///   - edges: Edges of the button. Default to softEdges if not provided.
        ///   - size: Size of the button. Default to collapsed if not provided.
        ///   - label: Label displayed next to the button's logo. Default to no label.
        public init(
            insets: NSDirectionalEdgeInsets? = nil,
            color: PayPalButton.Color = .gold,
            edges: PaymentButtonEdges = .softEdges,
            size: PaymentButtonSize = .collapsed,
            label: PayPalButton.Label? = nil,
            _ action: @escaping () -> Void = { }
        ) {
            button = PayPalButton(
                fundingSource: .payPal,
                color: color.color,
                edges: edges,
                size: size,
                insets: insets,
                label: label?.label
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

struct PayPalButtonView: View {

    var body: some View {
        PayPalButton.Representable()
    }
}

struct PayPalButtonView_Preview: PreviewProvider {

    static var previews: some View {
        PayPalButtonView()
    }
}
