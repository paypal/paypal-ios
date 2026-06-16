import UIKit
@testable import CorePayments

class MockURLOpener: URLOpener {

    var mockIsPayPalAppInstalled = false
    var mockIsVenmoAppInstalled = false
    var mockOpenURLSuccess = true
    var lastOpenedURL: URL?

    var didOpenURLHandler: (() -> Void)?

    func isPayPalAppInstalled() -> Bool {
        mockIsPayPalAppInstalled
    }

    func isVenmoAppInstalled() -> Bool {
        mockIsVenmoAppInstalled
    }

    func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        lastOpenedURL = url
        completion?(mockOpenURLSuccess)
        didOpenURLHandler?()
    }
}
