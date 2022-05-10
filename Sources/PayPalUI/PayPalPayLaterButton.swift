import UIKit
import SwiftUI

/// Configuration for PayPal PayLater button
public final class PayPalPayLaterButton: PaymentButton, UIViewRepresentable {

    /**
    Available colors for PayPalPayLaterButton.
    */
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

    /// SwiftUI button action
    var action: () -> Void = { }

    /// Initialize a PayPalPayLaterButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to gold if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .gold,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        _ action: @escaping () -> Void = { }
    ) {
        self.init(
            fundingSource: .payLater,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: .payLater
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
        let payPalCreditButton = self

        view.addSubview(payPalCreditButton)

        payPalCreditButton.addTarget(context.coordinator, action: #selector(Coordinator.onAction(_:)), for: .touchUpInside)

        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.action = action
    }
}
