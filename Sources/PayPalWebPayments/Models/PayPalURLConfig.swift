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

    /// True when neither `returnAppURL` nor `fallbackSchemeURL` is usable.
    /// A URL is unusable when it's nil, blank, or "scheme-only" (no host and no path,
    /// e.g. `myapp://` or `https://`) — i.e. it can't route the buyer back into the app.
    /// Defensive early-fail so `start()`/`vault()` can fail immediately without a network call;
    /// this is a guard, not full parity with Android's nullable `ReturnToAppUrlConfig`.
    var isReturnToAppConfigMissing: Bool {
        isUnusable(returnAppURL) && isUnusable(fallbackSchemeURL)
    }

    /// A URL is "unusable" for return-to-app routing if it's nil, blank after trimming, or
    /// scheme-only (no host and no meaningful path, e.g. `myapp://`, `https://`).
    private func isUnusable(_ url: URL?) -> Bool {
        guard let url else { return true }
        let trimmed = url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return true }
        let hasHost = !(url.host?.isEmpty ?? true)
        let hasPath = !url.path.isEmpty && url.path != "/"
        return !hasHost && !hasPath
    }
}
