import UIKit
import PayPal
import PaymentsCore

class PayPalDemoViewController: FeatureBaseViewController, PaymentButtonDelegate {

    // MARK: - UI Components
    
    let payPalButton = PayPalButton()
    
    let payPalCreditButton = PayPalCreditButton()

    // MARK: - View Lifecycle & UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        payPalButton.delegate = self
        payPalCreditButton.delegate = self

        payPalButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)
        payPalCreditButton.addTarget(self, action: #selector(paymentButtonTapped), for: .touchUpInside)

        view.addSubview(payPalButton)
        view.addSubview(payPalCreditButton)
        view.backgroundColor = .systemBackground

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            payPalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            payPalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),
            payPalButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            payPalButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            
            payPalCreditButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            payPalCreditButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),
            payPalCreditButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            payPalCreditButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
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
    
    @objc func paymentButtonTapped() {
        checkoutWithPayPal(orderID: orderID ?? "")
    }

    func checkoutWithPayPal(orderID: String) {
        let config = CoreConfig(clientID: DemoSettings.clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
        let payPalClient = PayPalClient(config: config, returnURL: DemoSettings.paypalReturnUrl)

        payPalClient.start(orderID: orderID, presentingViewController: self) { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .success(let result):
                self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: APPROVED")
                print("✅ Order is successfully approved and ready to be captured/authorized with result: \(result)")
            case .failure(let error):
                self.updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
                print("❌ There was an error: \(error)")
            case .cancellation:
                self.updateTitle("\(DemoSettings.intent) cancelled")
                print("❌ Buyer has cancelled the PayPal flow")
            }
        }
    }
}
