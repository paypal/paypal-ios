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

        displayDemoFeatureViewController()
    }

    @objc func settingsTapped() {
        let appSettingsViewController = IASKAppSettingsViewController()
        appSettingsViewController.showDoneButton = false
        navigationController?.pushViewController(appSettingsViewController, animated: true)
    }
    
    func displayDemoFeatureViewController() {
        let demoViewControllerType = DemoSettings.demoType.viewController
        let demoViewController = demoViewControllerType.init()
                
        addChild(demoViewController)
        view.addSubview(demoViewController.view)
        
        //  Currently now you can toggle b/w the orange(card) and purple(paypal) VCs after updating your settings.
        // TODO: - Make it cleaner. Do we want to present it as childVCs?
        // TODO: - Do we want a parent VC class with order creation & order processing logic? Include some type of footer in each demo VC that shows result status & "processOrder/auth/capture" button.
    }
    
}
