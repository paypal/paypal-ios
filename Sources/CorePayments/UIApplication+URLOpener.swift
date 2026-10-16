import UIKit

@_documentation(visibility: private)
@MainActor
public protocol URLOpener {
    func open(
        _ url: URL,
        universalLinksOnly: Bool,
        completionHandler completion: (@Sendable (Bool) -> Void)?
    )
}

public extension URLOpener {

    func open(_ url: URL, completionHandler: (@Sendable (Bool) -> Void)? = nil) {
        open(url, universalLinksOnly: true, completionHandler: completionHandler)
    }
}

extension UIApplication: URLOpener {

    public func open(
        _ url: URL,
        universalLinksOnly: Bool = true,
        completionHandler completion: (@Sendable (Bool) -> Void)?
    ) {
        let options: [UIApplication.OpenExternalURLOptionsKey: Any] = universalLinksOnly ? [.universalLinksOnly: true] : [:]
        open(url, options: options, completionHandler: completion)
    }
}
