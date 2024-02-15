import UIKit
import SwiftUI

/// Configuration for PayPal PayLater button
public final class PayPalPayLaterButton: PaymentButton {

    /// Available colors for PayPalPayLaterButton.
    public enum Color: String {
        case gold
        case white

        var color: PaymentButtonColor {
            PaymentButtonColor(rawValue: rawValue) ?? .gold
        }
    }

    /// Initialize a PayPalPayLaterButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to gold if not provided.
    ///   - shape: Shape of the button. Default to `.rounded` if not provided.
    ///   - size: Size of the button. Default to standard if not provided.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .gold,
        shape: PaymentButtonShape = .rounded,
        size: PaymentButtonSize = .standard,
        _ action: @escaping () -> Void = { }
    ) {
        self.init(
            fundingSource: .payLater,
            color: color.color,
            shape: shape,
            size: size,
            insets: insets,
            label: .payLater
        )
    }
}

public extension PayPalPayLaterButton {
    
    /// PayPalPayLaterButton for SwiftUI
    struct Representable: UIViewRepresentable {
        
        private let button: PayPalPayLaterButton
        private var action: () -> Void = { }
        
        /// Initialize a PayPalPayLaterButton
        /// - Parameters:
        ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
        ///   - color: Color of the button. Default to gold if not provided.
        ///   - shape: Shape of the button. Default to `.rounded` if not provided.
        ///   - size: Size of the button. Default to collapsed if not provided.
        public init(
            insets: NSDirectionalEdgeInsets? = nil,
            color: PayPalPayLaterButton.Color = .gold,
            shape: PaymentButtonShape = .rounded,
            size: PaymentButtonSize = .standard,
            _ action: @escaping () -> Void = { }
        ) {
            self.button = PayPalPayLaterButton(
                fundingSource: .payLater,
                color: color.color,
                shape: shape,
                size: size,
                insets: insets,
                label: .payLater
            )
            self.action = action
        }

        // MARK: - UIViewRepresentable methods
        // TODO: Make unit test for UIVRepresentable methods: https://engineering.paypalcorp.com/jira/browse/DTNOR-623
        
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
}


// MARK: PayLaterButton Preview

struct PayPalPayLaterButtonView: View {

    var body: some View {
        PayPalPayLaterButton.Representable()
    }
}

struct PayPalPayLaterButtonView_Preview: PreviewProvider {

    static var previews: some View {
        PayPalPayLaterButtonView()
    }
}
