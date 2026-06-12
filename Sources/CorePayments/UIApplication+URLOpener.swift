import UIKit

@_documentation(visibility: private)
public protocol URLOpener {
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    )
    func isPayPalAppInstalled() -> Bool
    func isVenmoAppInstalled() -> Bool
}

extension URLOpener {

    func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        open(url, options: [:], completionHandler: completion)
    }
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

    public func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    ) {
        UIApplication.shared.open(url, options: options, completionHandler: completion)
    }
}
