import Foundation

/// Deep link URLs used for app switch return and cancel flows.
public struct PayPalURLConfig {

    public let returnAppURL: URL
    public let cancelAppURL: URL
    public let fallbackSchemeURL: URL

    public init(returnAppURL: URL, cancelAppURL: URL, fallbackSchemeURL: URL) {
        self.returnAppURL = returnAppURL
        self.cancelAppURL = cancelAppURL
        self.fallbackSchemeURL = fallbackSchemeURL
    }
}
