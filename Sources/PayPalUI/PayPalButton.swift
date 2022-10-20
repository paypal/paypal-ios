import Foundation
import SwiftUI

public struct PayPalButton: UIViewRepresentable {
    
    private var action: () -> Void = { }
    
    private let button: UIPayPalButton
    
    /// Initialize a UIPayPalButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to gold if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    ///   - label: Label displayed next to the button's logo. Default to no label.
    public init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: UIPayPalButton.Color = .gold,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed,
        label: UIPayPalButton.Label? = nil,
        _ action: @escaping () -> Void = { }
    ) {
        button = UIPayPalButton(
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
