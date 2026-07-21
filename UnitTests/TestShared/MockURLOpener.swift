import Foundation
@testable import CorePayments

class MockURLOpener: URLOpener {

    var mockIsOsloppInstalled = false
    var mockIsPayPalAppInstalled = false
    var mockOpenURLSuccess = true
    var lastOpenedURL: URL?
    var lastUniversalLinksOnly: Bool?

    var didOpenURLHandler: (() -> Void)?

    func isPayPalAppInstalled() -> Bool {
        mockIsPayPalAppInstalled
    }
    
    func isOsloAppInstalled() -> Bool {
        mockIsOsloppInstalled
    }

    func open(_ url: URL, universalLinksOnly: Bool, completionHandler completion: ((Bool) -> Void)?) {
        lastOpenedURL = url
        lastUniversalLinksOnly = universalLinksOnly
        completion?(mockOpenURLSuccess)
        didOpenURLHandler?()
    }
}
