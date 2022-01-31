import UIKit
import PayPal
import PaymentsCore

class PayPalDemoViewController: FeatureBaseViewController {

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
            payPalButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: buttonSpacing),
            payPalButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            payPalCreditButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            payPalCreditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),
            payPalCreditButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -buttonSpacing),
            payPalCreditButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }

    // MARK: - FeatureBaseViewController Override

    /// Enable the PayPal Button once we have created an order
    func createOrder(completion: @escaping (String?) -> Void = { _ in }) {
        baseViewModel.createOrder(amount: amountTextField.text) { orderID in
            if orderID != nil {
                self.payPalButton.isEnabled = true
            } else {
                print("There was an error")
            }
        }
    }

    // MARK: - PayPal Module Integration

    @objc func paymentButtonTapped() {
        guard let orderID = baseViewModel.orderID else {
            baseViewModel.updateTitle("Failed: missing orderID.")
            return
        }

        checkoutWithPayPal(orderID: orderID)
    }

    func checkoutWithPayPal(orderID: String) {
        let config = CoreConfig(clientID: DemoSettings.clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
        let payPalClient = PayPalClient(config: config, returnURL: DemoSettings.paypalReturnUrl)
        let payPalRequest = PayPalRequest(orderID: orderID)

        payPalClient.start(request: payPalRequest, presentingViewController: self) { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .success(let result):
                self.baseViewModel.updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: APPROVED")
                print("✅ Order is successfully approved and ready to be captured/authorized with result: \(result)")
            case .failure(let error):
                self.baseViewModel.updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
                print("❌ There was an error: \(error)")
            case .cancellation:
                self.baseViewModel.updateTitle("\(DemoSettings.intent) canceled")
                print("❌ Buyer has canceled the PayPal flow")
            }
        }
    }
}
