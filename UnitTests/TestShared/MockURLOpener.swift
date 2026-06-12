import Foundation
import UIKit
@testable import CorePayments

class MockURLOpener: URLOpener {

    var mockIsPayPalAppInstalled = false
    var mockIsVenmoAppInstalled = false
    var mockOpenURLSuccess = true
    var lastOpenedURL: URL?
    var lastOpenOptions: [UIApplication.OpenExternalURLOptionsKey: Any]?

    var didOpenURLHandler: (() -> Void)?

    func isPayPalAppInstalled() -> Bool {
        mockIsPayPalAppInstalled
    }

    func isVenmoAppInstalled() -> Bool {
        mockIsVenmoAppInstalled
    }

    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey: Any],
        completionHandler completion: ((Bool) -> Void)?
    ) {
        lastOpenedURL = url
        lastOpenOptions = options
        completion?(mockOpenURLSuccess)
        didOpenURLHandler?()
    }
}
