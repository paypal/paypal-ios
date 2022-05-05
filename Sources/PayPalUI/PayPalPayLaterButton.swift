//
//  PayPalPayLaterButton.swift
//  PayPalUI
//
//  Created by Jose Noriega on 02/05/2022.
//

import UIKit
import SwiftUI

/// Configuration for PayPal PayLater button
public final class PayPalPayLaterButton: PaymentButton, UIViewRepresentable {

    /**
    Available colors for PayPalPayLaterButton.
    */
    @objc(PPCPayPalPayLaterButtonColor)
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

    /// SwiftUI button action
    var action: () -> Void = { }

    /// Initialize a PayPalPayLaterButton
    /// - Parameters:
    ///   - insets: Edge insets of the button, defining the spacing of the button's edges relative to its content.
    ///   - color: Color of the button. Default to gold if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    public convenience init(
        insets: NSDirectionalEdgeInsets,
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

    /// Initialize a PayPalPayLaterButton. The insets of the button will be set appropriately depending on the button's size.
    /// - Parameters:
    ///   - color: Color of the button. Default to gold if not provided.
    ///   - edges: Edges of the button. Default to softEdges if not provided.
    ///   - size: Size of the button. Default to collapsed if not provided.
    public convenience init(
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
            insets: nil,
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
