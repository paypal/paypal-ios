import UIKit
import SwiftUI

/// Configuration for PayPal button
public final class PayPalButton: PaymentButton, UIViewRepresentable {

    /// SwiftUI button action
    var action: () -> Void = { }

    /**
    Available colors for PayPalButton.
    */
    @objc(PPCPayPalButtonColor)
    public enum Color: Int, CaseIterable {
        case gold = 0
        case white = 1
        case black = 2
        case silver = 3
        case blue = 4

        var color: PaymentButtonColor {
            PaymentButtonColor(rawValue: rawValue) ?? .gold
        }

        public var description: String {
            color.description
        }
    }

    /**
    Available labels for PayPalButton.
    */
    @objc(PPCPayPalButtonLabel)
    public enum Label: Int, CaseIterable {
        /// Display no label
        case none = -1

        /// Display "Checkout" on the right side of the button's logo
        case checkout = 0

        /// Display "Buy now" on the right side of the button's logo
        case buyNow = 1

        /// Display "Pay with" on the left side of the button's logo
        case payWith = 2

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
        insets: NSDirectionalEdgeInsets,
        color: Color = .gold,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        label: Label = .none,
        _ action: @escaping () -> Void = { }
    ) {
        self.init(
            fundingSource: .payPal,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: label.label
        )
        self.action = action
    }

    /// Initialize a PayPalButton. The insets of the button will be set appropriately depending on the button's size.
    /// - Parameters:
    ///   - color: Color of the button. Default to gold if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    ///   - label: Label displayed next to the button's logo. Default to no label.
    public convenience init(
        color: Color = .gold,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        label: Label = .none,
        _ action: @escaping () -> Void = { }
    ) {
        self.init(
            fundingSource: .payPal,
            color: color.color,
            edges: edges,
            size: size,
            insets: nil,
            label: label.label
        )
        self.action = action
    }

    deinit {}

    // MARK: - UIViewRepresentable methods

    public func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let payPalButton = self

        view.addSubview(payPalButton)

        payPalButton.addTarget(context.coordinator, action: #selector(Coordinator.onAction(_:)), for: .touchUpInside)

        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.action = action
    }
}
