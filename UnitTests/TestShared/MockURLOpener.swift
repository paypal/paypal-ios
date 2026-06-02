import Foundation
@testable import CorePayments

class MockURLOpener: URLOpener {

    var mockIsPayPalAppInstalled = false
    var mockIsVenmoAppInstalled = false
    var mockOpenURLSuccess = true
    var lastOpenedURL: URL?

    var didOpenURLHandler: (() -> Void)?

    func isPayPalAppInstalled() -> Bool {
        return mockIsPayPalAppInstalled
    }

    func isVenmoAppInstalled() -> Bool {
        return mockIsVenmoAppInstalled
    }

    func open(_ url: URL, completionHandler completion: ((Bool) -> Void)?) {
        lastOpenedURL = url
        completion?(mockOpenURLSuccess)
        didOpenURLHandler?()
    }
}
