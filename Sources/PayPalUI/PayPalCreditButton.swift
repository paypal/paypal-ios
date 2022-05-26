import UIKit
import SwiftUI

/// Configuration for PayPal Credit button
public final class PayPalCreditButton: PaymentButton, UIViewRepresentable {

    /// SwiftUI button action
    var action: () -> Void = { }

    /**
    Available colors for PayPalCreditButton.
    */
    public enum Color: String {
        case white
        case black
        case darkBlue

        var color: PaymentButtonColor {
            PaymentButtonColor(rawValue: rawValue) ?? .darkBlue
        }
    }

    /// Initialize a PayPalCreditButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to dark blue if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .darkBlue,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        _ action: @escaping () -> Void = { }
    ) {
        self.init(
            fundingSource: PaymentButtonFundingSource.credit,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: nil
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
