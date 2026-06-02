import UIKit

@_documentation(visibility: private)
public protocol URLOpener {
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    )
    func isPayPalAppInstalled() -> Bool
}

@_documentation(visibility: private)
public struct DefaultURLOpener: URLOpener {

    private let application: UIApplication

    public init(application: UIApplication = .shared) {
        self.application = application
    }

    public func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    ) {
        application.open(url, options: options, completionHandler: completion)
    }

    public func isPayPalAppInstalled() -> Bool {
        guard let payPalURL = URL(string: "paypal://") else {
            return false
        }
        return application.canOpenURL(payPalURL)
    }
}
