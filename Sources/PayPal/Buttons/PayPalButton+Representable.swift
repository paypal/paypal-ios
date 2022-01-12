import SwiftUI

@available(iOS 13, *)
public extension PayPalButton {

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
            // Not needed currently
            context.coordinator.action = action
        }
    }
}
