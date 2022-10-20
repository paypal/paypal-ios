import UIKit
import SwiftUI

/// Configuration for PayPal Credit button
public final class UIPayPalCreditButton: PaymentButton {

    /**
    Available colors for UIPayPalCreditButton.
    */
    public enum Color: String {
        case white
        case black
        case darkBlue

        var color: PaymentButtonColor {
            PaymentButtonColor(rawValue: rawValue) ?? .darkBlue
        }
    }

    /// Initialize a UIPayPalCreditButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to dark blue if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    public convenience init(
        insets: NSDirectionalEdgeInsets? = nil,
        color: Color = .darkBlue,
        edges: PaymentButtonEdges = .softEdges,
        size: PaymentButtonSize = .collapsed
    ) {
        self.init(
            fundingSource: PaymentButtonFundingSource.credit,
            color: color.color,
            edges: edges,
            size: size,
            insets: insets,
            label: nil
        )
    }

    deinit {}
}
