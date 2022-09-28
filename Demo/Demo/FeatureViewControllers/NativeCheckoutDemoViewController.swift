import Foundation
import UIKit

class NativeCheckoutDemoViewController: FeatureBaseViewController {

    let viewModel = PayPalViewModel()

    init() {
        super.init(baseViewModel: BaseViewModel())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var nativeCheckoutButton: CustomButton = {
        let nativeCheckoutButton = CustomButton(title: "Native Checkout With OrderID")
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
            viewModel.checkoutWithOrderID()
            nativeCheckoutButton.stopAnimating()
        }
    }
}
