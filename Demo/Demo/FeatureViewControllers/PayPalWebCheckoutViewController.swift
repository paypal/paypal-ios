import UIKit
import PayPalWebCheckout
import PaymentsCore
import PayPalUI

class PayPalWebCheckoutViewController: FeatureBaseViewController {

    // MARK: - View Spacing

    let buttonSpacing: CGFloat = 60

    // MARK: - UI Components

    lazy var payPalButton: PayPalButton = {
        let payPalButton = PayPalButton(color: .silver, edges: .rounded, size: .full)
        payPalButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
        return payPalButton
    }()

    lazy var payPalCreditButton: PayPalCreditButton = {
        let payPalCreditButton = PayPalCreditButton(color: .darkBlue, edges: .softEdges, size: .mini)
        payPalCreditButton.addTarget(self, action: #selector(paymentCreditButtonTapped), for: .touchUpInside)
        return payPalCreditButton
    }()

    lazy var payPalPayLaterButton: PayPalPayLaterButton = {
        let payPalPayLaterButton = PayPalPayLaterButton(color: .gold, edges: .hardEdges, size: .full)
        payPalPayLaterButton.addTarget(self, action: #selector(paymentCreditButtonTapped), for: .touchUpInside)
        return payPalPayLaterButton
    }()

    // MARK: - View Lifecycle & UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(payPalButton)
        view.addSubview(payPalCreditButton)
        view.addSubview(payPalPayLaterButton)
        view.backgroundColor = .systemBackground

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            payPalButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -buttonSpacing),
            payPalButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            payPalCreditButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            payPalCreditButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            payPalPayLaterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: buttonSpacing),
            payPalPayLaterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
