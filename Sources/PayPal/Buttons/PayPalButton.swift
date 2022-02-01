import UIKit
import SwiftUI

/// Configuration for PayPal button
public final class PayPalButton: PaymentButton, UIViewRepresentable {

    /// SwiftUI button action
    var action: () -> Void = { }

    public init() {
        super.init(color: .gold, image: .payPal)
    }

    /// Initializer for the SwiftUI PayPal button
    /// - Parameter action: action of the button on click
    public init(_ action: @escaping () -> Void) {
        self.action = action
        super.init(color: .gold, image: .payPal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewRepresentable methods

    public func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let payPalButton = PayPalButton()

        view.addSubview(payPalButton)

        payPalButton.addTarget(context.coordinator, action: #selector(Coordinator.onAction(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            payPalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            payPalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            payPalButton.topAnchor.constraint(equalTo: view.topAnchor),
            payPalButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.action = action
    }
}
