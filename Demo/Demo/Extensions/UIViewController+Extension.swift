import UIKit

extension UIViewController {

    func removeChildViews() {
        children.forEach { viewController in
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
    }
}
