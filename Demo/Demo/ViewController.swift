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
        
        displayDemoTypeViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        // Note to Jax:
        // Moved this stuff to viewWillAppear to test the Settings toggles are properly working.
        // Also, the prod server is broken right now, so we will expect those requests to fail.
        displayDemoTypeViewController()
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
    
    func displayDemoTypeViewController() {
        let demoViewControllerType = DemoSettings.demoType.viewController
        let demoViewController = demoViewControllerType.init()
                
        addChild(demoViewController)
        view.addSubview(demoViewController.view)
        
        //  Currently now you can toggle b/w the orange(card) and purple(paypal) VCs after updating your settings.
        // TODO: - Make it cleaner. Do we want to present it as childVCs?
        // TODO: - Do we want a parent VC class with order creation & order processing logic? Include some type of footer in each demo VC that shows result status & "processOrder/auth/capture" button.
    }
    
}
