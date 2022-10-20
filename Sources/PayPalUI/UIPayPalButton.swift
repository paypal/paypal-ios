import UIKit
import SwiftUI

/// Configuration for PayPal button
public final class UIPayPalButton: PaymentButton {

    /// Available colors for UIPayPalButton.
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

    /// Available labels for UIPayPalButton.
    public enum Label: String {
        /// Display "Checkout" on the right side of the button's logo
        case checkout

        /// Display "Buy now" on the right side of the button's logo
        case buyNow

        /// Display "Pay with" on the left side of the button's logo
        case payWith

        var label: PaymentButtonLabel? {
            PaymentButtonLabel(rawValue: rawValue)
        }
    }

    /// Initialize a UIPayPalButton
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
