import UIKit
import SwiftUI

public struct PayPalCreditButton: UIViewRepresentable {

    private let button: UIPayPalCreditButton
    private var action: () -> Void = { }
        
    /// Initialize a PayPalCreditButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to dark blue if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    public init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: UIPayPalCreditButton.Color = .darkBlue,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        _ action: @escaping () -> Void = { }
    ) {
        self.button = UIPayPalCreditButton(
            fundingSource: PaymentButtonFundingSource.credit,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: nil
        )
        self.action = action
    }
    
    // MARK: - UIViewRepresentable methods

    public func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()

        view.addSubview(button)
        button.addTarget(context.coordinator, action: #selector(Coordinator.onAction(_:)), for: .touchUpInside)

        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.action = action
    }
}
