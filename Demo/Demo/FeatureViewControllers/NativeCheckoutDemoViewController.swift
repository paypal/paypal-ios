import Foundation
import UIKit

class NativeCheckoutDemoViewController: FeatureBaseViewController {

    let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var nativeCheckoutButton: CustomButton = {
        let nativeCheckoutButton = CustomButton(title: "Native Checkout")
        nativeCheckoutButton.addTarget(self, action: #selector(didTapNativeCheckoutButton), for: .touchUpInside)
        nativeCheckoutButton.layer.cornerRadius = 8
        nativeCheckoutButton.backgroundColor = .systemBlue
        nativeCheckoutButton.tintColor = .white
        return nativeCheckoutButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        stackView.addArrangedSubview(nativeCheckoutButton)
        view.addSubview(stackView)

        NSLayoutConstraint.activate(
            [
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: Constants.layoutSpacing)
            ]
        )
    }

    @objc func didTapNativeCheckoutButton() {
        Task {
            nativeCheckoutButton.startAnimating()
            guard let orderId = baseViewModel.orderID else {
                return
            }
            _ = try await baseViewModel.checkoutWithNativeClient(orderId: orderId)
            nativeCheckoutButton.stopAnimating()
        }
    }
}
