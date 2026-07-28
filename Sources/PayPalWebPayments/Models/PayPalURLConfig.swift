import Foundation

/// Deep link URLs used for app switch return and cancel flows.
public struct PayPalURLConfig {

    public let returnAppURL: URL
    public let cancelAppURL: URL
    public let fallbackSchemeURL: URL?

    public init(returnAppURL: URL, cancelAppURL: URL, fallbackSchemeURL: URL?) {
        self.returnAppURL = returnAppURL
        self.cancelAppURL = cancelAppURL
        self.fallbackSchemeURL = fallbackSchemeURL
    }
}

extension PayPalURLConfig {

    /// True when neither `returnAppURL` nor `fallbackSchemeURL` is usable (both nil/blank).
    /// Mirrors Android's ReturnToAppUrlConfig validation.
    var isReturnToAppConfigMissing: Bool {
        func isBlank(_ url: URL?) -> Bool {
            guard let url else { return true }
            return url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return isBlank(returnAppURL) && isBlank(fallbackSchemeURL)
    }
}
