import UIKit

class FeatureBaseViewController: UIViewController {

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
    }

    func configureBottomView() {
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    func fetchOrderID() {
        // TODO: The prod server is broken right now, so we will expect those requests to fail.
        // TODO: Pass order details into this function

        let amount = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amount)]
        )

        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { result in
            self.processOrder(status: "Processing your order")
            switch result {
            case .success(let order):
                self.processOrder(status: "Successfully \(order.status.lowercased()) your order")
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
                DispatchQueue.main.async {
                    self.displayAlert(message: "Order ID: \(order.id) has a status of \(order.status.lowercased())", success: true)
                }
            case .failure(let error):
                self.processOrder(status: "Your order has failed, please try again")
                print("❌ failed to fetch orderID: \(error)")
                DispatchQueue.main.async {
                    self.displayAlert(message: "Error: \(error)", success: false)
                }
            }
        }
    }

    // TODO: Do we need this/the bottom container or are we fine using the alert function instead to display these details?
    func processOrder(status: String) {
        DispatchQueue.main.async {
            self.titleLabel.text = status
        }
    }

    private func displayAlert(message: String, success: Bool) {
        let successTitle = "😎 Successful Order"
        let failureTitle = "😕 Failed Order"
        let title = success ? successTitle : failureTitle

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }

        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
    }
}
