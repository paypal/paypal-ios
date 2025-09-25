import UIKit

@_documentation(visibility: private)
public protocol URLOpener {
    func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?)
    func isPayPalAppInstalled() -> Bool
}

extension UIApplication: URLOpener {

    public func isPayPalAppInstalled() -> Bool {
        guard let payPalURL = URL(string: "paypal-app-switch-checkout://") else {
            return false
        }
        return canOpenURL(payPalURL)
    }

    public func open (_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
