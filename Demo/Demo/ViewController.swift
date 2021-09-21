import UIKit
import Card
import PayPal
import InAppSettingsKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsTapped))

        // TODO: Update Demo UI with proper Card & PayPal checkout demos
        fetchOrderID()
    }

    @objc func settingsTapped() {
        let appSettingsViewController = IASKAppSettingsViewController()
        navigationController?.pushViewController(appSettingsViewController, animated: true)
    }

    func fetchOrderID() {
        let amount = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(
            intent: "CAPTURE",
            purchaseUnits: [PurchaseUnit(amount: amount)]
        )

        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { result in
            switch result {
            case .success(let order):
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            case .failure(let error):
                print(error)
            }
        }
    }
}
