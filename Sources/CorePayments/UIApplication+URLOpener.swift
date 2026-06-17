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

    public func isVenmoAppInstalled() -> Bool {
        guard let venmoURL = URL(string: "venmo://") else {
            return false
        }
        return canOpenURL(venmoURL)
    }

    public func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [.universalLinksOnly: true], completionHandler: completion)
    }
}
