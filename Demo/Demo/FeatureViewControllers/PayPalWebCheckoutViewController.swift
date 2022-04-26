import UIKit
import PayPalWebCheckout
import PaymentsCore
import PayPalUI

class PayPalWebCheckoutViewController: FeatureBaseViewController {

    // MARK: - View Spacing

    let buttonSpacing: CGFloat = 50

    // MARK: - UI Components

    lazy var payPalButton: PayPalButton = {
        let payPalButton = PayPalButton()
        payPalButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
        payPalButton.layer.cornerRadius = 4.0
        return payPalButton
    }()

    lazy var payPalCreditButton: PayPalCreditButton = {
        let payPalCreditButton = PayPalCreditButton()
        payPalCreditButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
        payPalCreditButton.layer.cornerRadius = 4.0
        return payPalCreditButton
    }()

    // MARK: - View Lifecycle & UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(payPalButton)
        view.addSubview(payPalCreditButton)
        view.backgroundColor = .systemBackground

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            payPalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            payPalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),
            payPalButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -buttonSpacing),
            payPalButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            payPalCreditButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            payPalCreditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),
            payPalCreditButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: buttonSpacing),
            payPalCreditButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }

    // MARK: - FeatureBaseViewController Override

    /// Enable the PayPal Button once we have created an order
    func createOrder() async {
        let orderID = await baseViewModel.createOrder(amount: amountTextField.text)
        if orderID != nil {
            self.payPalButton.isEnabled = true
        } else {
            print("There was an error")
        }
    }

    // MARK: - PayPal Module Integration

    @objc func paymentButtonTapped() {
        baseViewModel.payPalButtonTapped(context: self)
    }

    @objc func paymentCreditButtonTapped() {
        baseViewModel.payPalCreditButtonTapped(context: self)
    }
}
