import Foundation

/// Deep link URLs used for app switch return and cancel flows.
public struct PayPalURLConfig {

    public let returnAppUrl: String
    public let cancelAppUrl: String
    public let fallbackSchemeUrl: String?

    public init(returnAppUrl: String, cancelAppUrl: String, fallbackSchemeUrl: String? = nil) {
        self.returnAppUrl = returnAppUrl
        self.cancelAppUrl = cancelAppUrl
        self.fallbackSchemeUrl = fallbackSchemeUrl
    }
}
