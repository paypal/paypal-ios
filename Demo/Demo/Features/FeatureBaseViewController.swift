import UIKit

enum OrderState {
    case notStarted
    case orderProcessing
    case orderCreated
    case orderFailed
}

enum PaymentMethod: String {
    case card = "card"
    case paypal = "PayPal"
}

class FeatureBaseViewController: UIViewController {

    lazy var processOrderButton: UIButton = {
        let processOrderButton = button(
            title: "\(DemoSettings.intent.rawValue.capitalized) Order",
            action: #selector(didTapProcessOrderButton)
        )
        return processOrderButton
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBottomView()
        processOrderButton.isHidden = true
    }

    func configureBottomView() {
        view.addSubview(processOrderButton)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            processOrderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            processOrderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            processOrderButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: processOrderButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    func fetchOrderID(paymentMethod: PaymentMethod) {
        // TODO: The prod server is broken right now, so we will expect those requests to fail.
        // TODO: Pass order details into this function

        let amount = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amount)]
        )

        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { result in
            switch result {
            case .success(let order):
                self.processOrder(paymentMethod: paymentMethod, orderID: order.id, state: .orderCreated)
                DispatchQueue.main.async {
                    self.processOrderButton.isHidden = false
                }
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            case .failure(let error):
                self.processOrder(paymentMethod: paymentMethod, state: .orderFailed)
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }

    func processOrder(paymentMethod: PaymentMethod, orderID: String? = nil, state: OrderState) {
        let message: String

        switch state {
        case .notStarted:
            message = "Enter your \(paymentMethod) details to begin"
        case .orderProcessing:
            message = "Processing your \(paymentMethod) order"
        case .orderCreated:
            message = "Order ID: \(orderID ?? "")"
        case .orderFailed:
            message = "Your order has failed, please try again"
        }

        DispatchQueue.main.async {
            self.titleLabel.text = message
        }
    }

    @objc func didTapProcessOrderButton() {
        // TODO: Add thing to process the order here!
    }
}
