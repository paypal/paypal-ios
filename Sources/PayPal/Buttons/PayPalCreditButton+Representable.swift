import SwiftUI

@available(iOS 13, *)
public extension PayPalCreditButton {

    struct Representable: UIViewRepresentable {

        let action: () -> Void

        public init(_ action: @escaping () -> Void) {
            self.action = action
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
            // Not needed currently
            context.coordinator.action = action
        }
    }
}
