import UIKit
import SwiftUI

/// Configuration for PayPal Credit button
public final class PayPalCreditButton: PaymentButton {

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
    ///   - color: Color of the button. Default to gold if not provided.
    ///   - shape: Shape of the button. Default to `.rounded` if not provided.
    ///   - size: Size of the button. Default to standard if not provided.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .white,
        shape: PaymentButtonShape = .rounded,
        size: PaymentButtonSize = .standard
    ) {
        self.init(
            fundingSource: PaymentButtonFundingSource.credit,
            color: color.color,
            shape: shape,
            size: size,
            insets: insets,
            label: nil
        )
    }

    deinit {}
}

public extension PayPalCreditButton {
    
    /// PayPalCreditButton for SwiftUI
    struct Representable: UIViewRepresentable {
        
        private let button: PayPalCreditButton
        private var action: () -> Void = { }
            
        /// Initialize a PayPalCreditButton
        /// - Parameters:
        ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
        ///   - color: Color of the button. Default to gold if not provided.
        ///   - shape: Shape of the button. Default to `.rounded` if not provided.
        ///   - size: Size of the button. Default to standard if not provided.
        public init(
            insets: NSDirectionalEdgeInsets? = nil,
            color: PayPalCreditButton.Color = .white,
            shape: PaymentButtonShape = .rounded,
            size: PaymentButtonSize = .standard,
            _ action: @escaping () -> Void = { }
        ) {
            self.button = PayPalCreditButton(
                fundingSource: PaymentButtonFundingSource.credit,
                color: color.color,
                shape: shape,
                size: size,
                insets: insets,
                label: nil
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

// MARK: PayPalCreditButton Preview

struct PayPalCreditButtonView: View {

    var body: some View {
        PayPalCreditButton.Representable()
    }
}

struct PayPalCreditButtonView_Preview: PreviewProvider {

    static var previews: some View {
        PayPalCreditButtonView()
    }
}
