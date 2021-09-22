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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // TODO: Update Demo UI with proper Card & PayPal checkout demos
        
        // Note to Jax:
        // Moved this to viewWillAppear to test that it gets called with proper env after toggling in Settings
        // The prod server is broken right now, so we will expect those requests to fail.
        fetchOrderID()
    }

    @objc func settingsTapped() {
        let appSettingsViewController = IASKAppSettingsViewController()
        navigationController?.pushViewController(appSettingsViewController, animated: true)
        // TODO: Get rid of "done" button on InAppSettings screen
    }

    func fetchOrderID() {
        let amount = Amount(currencyCode: "USD", value: "10.00")
        let orderRequestParams = CreateOrderParams(
            intent: DemoSettings.intent.rawValue.uppercased(),
            purchaseUnits: [PurchaseUnit(amount: amount)]
        )

        DemoMerchantAPI.sharedService.createOrder(orderParams: orderRequestParams) { result in
            switch result {
            case .success(let order):
                print("✅ fetched orderID: \(order.id) with status: \(order.status)")
            case .failure(let error):
                print("❌ failed to fetch orderID: \(error)")
            }
        }
    }
}
