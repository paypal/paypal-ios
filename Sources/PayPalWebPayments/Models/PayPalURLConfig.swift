import Foundation

/// Deep link URLs used for app switch return and cancel flows.
public struct PayPalURLConfig {

    public let returnAppURL: String
    public let cancelAppURL: String
    public let fallbackSchemeURL: String

    public init(returnAppUrl: String, cancelAppUrl: String, fallbackSchemeUrl: String) {
        self.returnAppURL = returnAppUrl
        self.cancelAppURL = cancelAppUrl
        self.fallbackSchemeURL = fallbackSchemeUrl
    }
}
