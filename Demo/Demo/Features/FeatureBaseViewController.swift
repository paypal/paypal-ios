import UIKit

class FeatureBaseViewController: UIViewController {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        fetchOrderID()
    }
    
    func configureBottomView() {
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
        ])
    }
    
    func fetchOrderID() {
        // TODO: - The prod server is broken right now, so we will expect those requests to fail.

        let amount = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amount)]
        )

        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { result in
            switch result {
            case .success(let order):
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
                DispatchQueue.main.async {
                    self.processOrder(orderID: order.id, status: order.status, success: true)
                }
            case .failure(let error):
                print("❌ failed to fetch orderID: \(error)")
                DispatchQueue.main.async {
                    self.processOrder(orderID: nil, status: nil, success: false)
                }
            }
        }
    }
    
    func processOrder(orderID: String?, status: String?, success: Bool) {
        // TODO: - Update progress bar/ toolbar to show status of demo (order fetched, processing, etc)
        let successText = "😎 Order ID: \(orderID ?? "") Status: \(status ?? "")"
        let failureText = "😕 Failed to create order"

        titleLabel.text = success ? successText : failureText
    }
    
}
