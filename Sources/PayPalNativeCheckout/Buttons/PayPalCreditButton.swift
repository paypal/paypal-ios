import UIKit
import SwiftUI

/// Configuration for PayPal Credit button
public final class PayPalCreditButton: PaymentButton, UIViewRepresentable {

    /// SwiftUI button action
    var action: () -> Void = { }

    public init() {
        super.init(color: .darkBlue, image: .payPalCredit)
    }

    /// Initilizer for the SwiftUI PayPal button
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
        let payPalCreditButton = PayPalCreditButton()

        view.addSubview(payPalCreditButton)

        payPalCreditButton.addTarget(context.coordinator, action: #selector(Coordinator.onAction(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            payPalCreditButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            payPalCreditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            payPalCreditButton.topAnchor.constraint(equalTo: view.topAnchor),
            payPalCreditButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.action = action
    }
}
