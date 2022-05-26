import UIKit

extension UIViewController {

    func removeChildViews() {
        children.forEach { viewController in
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }

    func label(_ text: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = text
        return label
    }
}
