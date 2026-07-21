import UIKit

@_documentation(visibility: private)
public protocol URLOpener {
    func open(
        _ url: URL,
        universalLinksOnly: Bool,
        completionHandler completion: ((Bool) -> Void)?
    )
    func isPayPalAppInstalled() -> Bool
    func isOsloAppInstalled() -> Bool
}

public extension URLOpener {

    func open(_ url: URL, completionHandler: ((Bool) -> Void)? = nil) {
        open(url, universalLinksOnly: true, completionHandler: completionHandler)
    }
}

extension UIApplication: URLOpener {

    public func isPayPalAppInstalled() -> Bool {
        guard let payPalURL = URL(string: "paypal://") else {
            return false
        }
        return canOpenURL(payPalURL)
    }
    
    public func isOsloAppInstalled() -> Bool {
        guard let osloURL = URL(string: "paypal-oslo://") else {
            return false
        }
        return canOpenURL(osloURL)
    }

    public func open(
        _ url: URL,
        universalLinksOnly: Bool = true,
        completionHandler completion: ((Bool) -> Void)?
    ) {
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = universalLinksOnly ? [.universalLinksOnly: true] : [:]
        open(url, options: options, completionHandler: completion)
    }
}
