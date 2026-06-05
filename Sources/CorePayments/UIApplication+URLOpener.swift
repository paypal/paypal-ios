import UIKit

@_documentation(visibility: private)
public protocol URLOpener {
    func open(
        _ url: URL,
        universalLinksOnly: Bool,
        completionHandler completion: ((Bool) -> Void)?
    )
    func isPayPalAppInstalled() -> Bool
}

extension UIApplication: URLOpener {

    public func isPayPalAppInstalled() -> Bool {
        guard let payPalURL = URL(string: "paypal://") else {
            return false
        }
        return canOpenURL(payPalURL)
    }

    public func open(
        _ url: URL,
        universalLinksOnly: Bool,
        completionHandler completion: ((Bool) -> Void)?
    ) {
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = universalLinksOnly ? [.universalLinksOnly: true] : [:]
        open(url, options: options, completionHandler: completion)
    }
}
