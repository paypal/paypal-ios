import UIKit
import PaymentsCore

class FeatureBaseViewController: UIViewController {

    enum Constants {
        static let stackViewSpacing: CGFloat = 16
        static let layoutSpacing: CGFloat = 16
        static let textFieldHeight: CGFloat = 40
    }

    lazy var createOrderStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var amountTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "Amount", defaultValue: "10.00")
        textField.keyboardType = .decimalPad
        return textField
    }()

    lazy var createOrderButton: CustomButton = {
        let createOrderButton = CustomButton(title: "Create Order")
        createOrderButton.addTarget(self, action: #selector(createOrderTapped), for: .touchUpInside)
        return createOrderButton
    }()

    lazy var bottomStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    var orderID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBottomView()
        updateTitle("Tap create order to begin")
    }

    func configureBottomView() {
        view.addSubview(createOrderStackView)
        createOrderStackView.addArrangedSubview(amountTextField)
        createOrderStackView.addArrangedSubview(createOrderButton)
        view.addSubview(bottomStatusLabel)

        NSLayoutConstraint.activate([
            createOrderStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.layoutSpacing),
            createOrderStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.layoutSpacing
            ),
            createOrderStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Constants.layoutSpacing
            ),

            amountTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            bottomStatusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomStatusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomStatusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.layoutSpacing)
        ])
    }

    @objc func createOrderTapped() {
        createOrder()
    }

    func createOrder(completion: @escaping (String?) -> Void = { _ in }) {
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
            DispatchQueue.main.async {
                completion(self.orderID)
            }
        }
    }

    func processOrder(orderData: OrderData, completion: @escaping () -> Void = {}) {
        switch DemoSettings.intent {
        case .authorize:
            updateTitle("Authorizing order...")
        case .capture:
            updateTitle("Capturing order...")
        }

        let processOrderParams = ProcessOrderParams(
            orderId: orderData.orderID,
            intent: DemoSettings.intent.rawValue,
            countryCode: "US"
        )

        DemoMerchantAPI.sharedService.processOrder(processOrderParams: processOrderParams) { result in
            switch result {
            case .success(let order):
                self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) success: \(order.status)")
                print("✅ processed orderID: \(order.id) with status: \(order.status)")
            case .failure(let error):
                self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) fail: \(error.localizedDescription)")
                print("❌ failed to process orderID: \(error)")
            }
            completion()
        }
    }

    func updateTitle(_ message: String) {
        DispatchQueue.main.async {
            self.bottomStatusLabel.text = message
        }
    }
}
