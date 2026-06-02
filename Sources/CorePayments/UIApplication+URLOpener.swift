import UIKit

@_documentation(visibility: private)
public protocol URLOpener {
    func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?)
    func isPayPalAppInstalled() -> Bool
    func isVenmoAppInstalled() -> Bool
}

extension UIApplication: URLOpener {

    public func isPayPalAppInstalled() -> Bool {
        guard let payPalURL = URL(string: "paypal://") else {
            return false
        }
        return canOpenURL(payPalURL)
    }

    // swiftlint:disable force_unwrapping
    public func isVenmoAppInstalled() -> Bool {
        canOpenURL(URL(string: "com.venmo.touch.v2://")!)
    }
    // swiftlint:enable force_unwrapping

    public func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}
