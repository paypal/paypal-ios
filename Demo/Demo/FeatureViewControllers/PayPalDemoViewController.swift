import UIKit
import PayPal
import PaymentsCore

class PayPalDemoViewController: FeatureBaseViewController {

    // MARK: - UI Components

    lazy var payPalButton: CustomButton = {
        let payPalButton = CustomButton(title: "PayPal")
        payPalButton.addTarget(self, action: #selector(didTapPayPalButton), for: .touchUpInside)
        payPalButton.layer.cornerRadius = 8
        payPalButton.backgroundColor = .systemBlue
        payPalButton.tintColor = .white
        payPalButton.isEnabled = false
        return payPalButton
    }()

    // MARK: - View Lifecycle & UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(payPalButton)
        view.backgroundColor = .systemBackground

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            payPalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            payPalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),
            payPalButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            payPalButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }

    // MARK: - FeatureBaseViewController Override

    /// Enable the PayPal Button once we have created an order
    override func createOrder(completion: @escaping (String?) -> Void = { _ in }) {
        super.createOrder { orderID in
            if orderID != nil {
                self.payPalButton.isEnabled = true
            } else {
                print("There was an error")
            }
        }
    }

    // MARK: - PayPal Module Integration

    @objc func didTapPayPalButton() {
        checkoutWithPayPal(orderID: baseViewModel.orderID ?? "")
    }

    func checkoutWithPayPal(orderID: String) {
        let config = CoreConfig(clientID: DemoSettings.clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
        let payPalClient = PayPalClient(config: config, returnURL: DemoSettings.paypalReturnUrl)

        payPalClient.start(orderID: orderID, presentingViewController: self) { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .success(let result):
                self.baseViewModel.updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: APPROVED")
                print("✅ Order is successfully approved and ready to be captured/authorized with result: \(result)")
            case .failure(let error):
                self.baseViewModel.updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
                print("❌ There was an error: \(error)")
            case .cancellation:
                self.baseViewModel.updateTitle("\(DemoSettings.intent) cancelled")
                print("❌ Buyer has cancelled the PayPal flow")
            }
        }
    }
}
