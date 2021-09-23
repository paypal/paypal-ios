import UIKit

// TODO: Should this be a base view controller or should we just have this as a class for our views to inherit from?
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
        configureBottomView()
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
        let okayAction = UIAlertAction(title: "Okay", style: .default) { action in
            self.navigationController?.popViewController(animated: true)
        }

        alertController.addAction(okayAction)
        present(alertController, animated: true, completion: nil)
    }
}
