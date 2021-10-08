import UIKit
import Card
import PayPal
import InAppSettingsKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }

        let settingsButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsTapped))
        navigationItem.rightBarButtonItem = settingsButton
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
        demoViewController.modalPresentationStyle = .fullScreen

        navigationItem.title = DemoSettings.demoType.rawValue.uppercased()

        addChild(demoViewController)
        view.addSubview(demoViewController.view)
    }
}
