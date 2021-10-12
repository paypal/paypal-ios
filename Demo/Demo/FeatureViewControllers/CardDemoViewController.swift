import UIKit
import PaymentsCore
import Card

class CardDemoViewController: FeatureBaseViewController {
    // TODO: Validate card fields are filled out
    // TODO: Add proper spacing / styling / max characters to card fields
    // TODO: Animate pay button to indicate loading
    // TODO: Disable pay button until fields are filled out

    // MARK: - PayPal SDK Setup

    let coreConfig = CoreConfig(
        clientID: DemoSettings.clientID,
        environment: DemoSettings.environment.paypalSDKEnvironment
    )

    lazy var cardClient: CardClient = {
        CardClient(config: coreConfig)
    }()

    // MARK: - UI Components

    typealias Constants = FeatureBaseViewController.Constants

    let cardFormStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    let expirationCVVStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var cardNumberTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "Card Number")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var expirationTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "Expiration")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var cvvTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "CVV")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var payButton: CustomButton = {
        let payButton = CustomButton(title: "\(DemoSettings.intent.rawValue.capitalized) Order")
        payButton.addTarget(self, action: #selector(didTapPayButton), for: .touchUpInside)
        payButton.layer.cornerRadius = 8
        payButton.backgroundColor = .systemBlue
        payButton.tintColor = .white
        return payButton
    }()

    // MARK: - View Lifecycle & UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        view.addSubview(cardFormStackView)

        cardFormStackView.addArrangedSubview(cardNumberTextField)
        cardFormStackView.addArrangedSubview(expirationCVVStackView)
        cardFormStackView.addArrangedSubview(payButton)

        expirationCVVStackView.addArrangedSubview(expirationTextField)
        expirationCVVStackView.addArrangedSubview(cvvTextField)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardFormStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardFormStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            cardFormStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),

            cardNumberTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            expirationTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            cvvTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            payButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }

    // MARK: - Card Module Integration

    @objc func didTapPayButton() {
        updateTitle("Approving order...")

        guard let card = createCard(),
            let orderID = orderID else {
            updateTitle("Failed: missing card / orderID.")
            return
        }

        cardClient.approveOrder(orderID: orderID, card: card) { result in
            switch result {
            case .success(let orderData):
                if let orderStatus = orderData.status {
                    self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: \(orderStatus.rawValue)")
                }
                self.processOrder(orderData: orderData)
            case .failure(let error):
                self.updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
            }
        }
    }

    func createCard() -> Card? {
        guard let cardNumber = cardNumberTextField.text,
            let cvv = cvvTextField.text,
            let expirationDate = expirationTextField.text else {
            return nil
        }

        // TODO: Require 4 digit year & don't crash otherwise
        let expirationComponents = expirationDate.components(separatedBy: "/")
        let expirationMonth = expirationComponents[0]
        let expirationYear = expirationComponents[1]

        return Card(number: cardNumber, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: cvv)
    }

    func processOrder(orderData: OrderData) {
        updateTitle("Authorizing/Capturing order ...")

        let processOrderParams = ProcessOrderParams(
            orderId: orderData.orderID,
            intent: DemoSettings.intent.rawValue,
            countryCode: "US"
        )

        // TODO: Investigate why sample server is failing to capture/authorize

        DemoMerchantAPI.sharedService.processOrder(processOrderParams: processOrderParams) { result in
            switch result {
            case .success(let order):
                self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) success: \(order.status)")
                print(order)
            case .failure(let error):
                self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) fail: \(error.localizedDescription)")
                print(error)
            }
        }
    }
}
