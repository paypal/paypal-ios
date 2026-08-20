import Foundation
@testable import CorePayments

class MockURLOpener: URLOpener {

    var mockOpenURLSuccess = true
    var lastOpenedURL: URL?
    var lastUniversalLinksOnly: Bool?

    var didOpenURLHandler: (() -> Void)?

    func open(_ url: URL, universalLinksOnly: Bool, completionHandler completion: ((Bool) -> Void)?) {
        lastOpenedURL = url
        lastUniversalLinksOnly = universalLinksOnly
        completion?(mockOpenURLSuccess)
        didOpenURLHandler?()
    }
}
