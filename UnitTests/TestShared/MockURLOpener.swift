import UIKit
@testable import CorePayments

class MockURLOpener: URLOpener {

    var mockIsPayPalAppInstalled = false
    var mockOpenURLSuccess = true
    var lastOpenedURL: URL?

    var didOpenURLHandler: (() -> Void)?

    func isPayPalAppInstalled() -> Bool {
        return mockIsPayPalAppInstalled
    }

    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any], completionHandler completion: ((Bool) -> Void)?) {
        lastOpenedURL = url
        completion?(mockOpenURLSuccess)
        didOpenURLHandler?()
    }
}
