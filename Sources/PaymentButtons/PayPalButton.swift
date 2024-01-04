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
        
        /// Use on a website or app where the term ‘add money’ is used for a customer adding money to an account.
        /// Add label to the left of the PayPal logo.
        case addMoneyWith = "Add Money with"

        /// Use on product detail pages where customers are reserving an experience or service.
        /// Add label to the left of the PayPal logo.
        case bookWith = "Book with"

        /// Recommended for use on product detail pages to help give customers context on the resulting action.
        /// Add label to the left of the PayPal logo.
        case buyWith = "Buy with"

        /// Add label to the left of the PayPal logo.
        case buyNowWith = "Buy Now with"

        /// Recommended for use on cart and checkout pages, where there is a purchasing context. Add label to the left of the PayPal logo.
        case checkoutWith = "Checkout with"

        /// Use as the call to action on a checkout page when PayPal is the selected payment method, and
        /// the customer will return to the website or app to complete the purchase. Add label to the left of the PayPal logo.
        case continueWith = "Continue with"

        /// Add "Contribute" to the left of the PayPal logo. Add label to the left of the PayPal logo.
        case contributeWith = "Contribue with"

        /// Use on a website or app where a customer is placing an order, commonly associated with food purchases.
        /// Add label to the left of the PayPal logo.
        case orderWith = "Order with"

        /// Add "Pay later" to the right of button's logo, only used for PayPalPayLaterButton.
        /// Add label to the right of the PayPal logo.
        case payLater = "Pay Later"

        /// Add label to the left of the PayPal logo.
        case payLaterWith = "Pay Later with"

        /// Recommended for use on pages where customers are paying bills or invoices. Add label to the left of the PayPal logo.
        case payWith = "Pay with"

        /// Use on a website or app where the term ‘reload’ is used for a customer adding money to an account.
        /// Add label to the left of the PayPal logo.
        case reloadWith = "Reload with"

        /// Use when a customer is renting an item. Add label to the left of the PayPal logo.
        case rentWith = "Rent with"

        /// Add label to the left of the PayPal logo.
        case reserveWith = "Reserve with"

        /// Use when a customer will start opt in to recurring payments to your store. Add label to the left of the PayPal logo.
        case subscribeWith = "Subscribe with"

        /// Add "Support with" to the left of the PayPal logo. Add label to the left of the PayPal logo.
        case supportWith = "Support with"

        /// Use when a customer is tipping for an item or service. Add label to the left of the PayPal logo.
        case tipWith = "Tip with"

        /// Use on a website or app where the term ‘top up’ is used for a customer adding money to an account.
        /// Add label to the left of the PayPal logo.
        case topUpWith = "Top Up with"

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
