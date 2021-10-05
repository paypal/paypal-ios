import UIKit

class FeatureBaseViewController: UIViewController {

    private enum Constants {
        static let stackViewSpacing: CGFloat = 16
        static let layoutSpacing: CGFloat = 16
    }

    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var amountTextField: UITextField = {
        let textField = textField(placeholder: "Amount")
        textField.text = "10.00"
        textField.keyboardType = .decimalPad
        return textField
    }()

    lazy var createOrderButton: UIButton = {
        let createOrderButton = button(title: "Create Order", action: #selector(createOrderTapped))
        createOrderButton.tintColor = .systemPink
        return createOrderButton
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var orderID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBottomView()
        updateTitle("Tap create order to begin")
    }

    func configureBottomView() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(amountTextField)
        stackView.addArrangedSubview(createOrderButton)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.layoutSpacing),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.layoutSpacing),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.layoutSpacing),

            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.layoutSpacing)
        ])
    }

    @objc func createOrderTapped() {
        // TODO: The prod server is broken right now, so we will expect those requests to fail.

        updateTitle("Creating order...")

        let amount = Amount(currencyCode: "USD", value: amountTextField.text ?? "")
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amount)]
        )

        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { result in
            switch result {
            case .success(let order):
                self.updateTitle("Order ID: \(order.id)")
                self.orderID = order.id
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            case .failure(let error):
                self.updateTitle("Your order has failed, please try again")
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }

    func processOrder() {
        // TODO: Pass in card details once card client is merged and call processOrder from DemoMerchantAPI
    }

    func updateTitle(_ message: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = message
        }
    }
}
