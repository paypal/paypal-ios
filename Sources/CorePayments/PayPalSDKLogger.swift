import Foundation

/// Centralized debug logging for the PayPal SDK.
///
/// Every debug `print` in the SDK funnels through this type so logging can be toggled or removed in a
/// single place:
/// - To silence all output at runtime, set `PayPalSDKLogger.isEnabled = false`.
/// - To remove logging entirely, delete this file and the `PayPalSDKLogger.…` call sites (the compiler
///   will flag each one for you).
@_documentation(visibility: private)
public enum PayPalSDKLogger {

    /// Master switch for all SDK debug logging. Set to `false` to silence everything.
    public static var isEnabled = true

    /// URL substrings whose network traffic is excluded from logging, to reduce noise.
    private static let excludedURLFragments = ["/v1/tracking/events"]

    // MARK: - Generic

    /// Logs a single line. Prefer the structured helpers below where they fit.
    public static func log(_ message: String) {
        guard isEnabled else { return }
        print(message)
    }

    // MARK: - Network

    /// Logs an outgoing HTTP request (method, URL, headers, and body).
    public static func logRequest(
        method: String,
        url: URL,
        headers: [HTTPHeader: String],
        body: Data?
    ) {
        guard shouldLog(url) else { return }

        var lines = [
            "",
            "┌─────────────────────────────────────────────────────────────",
            "│ [PayPal SDK] ➡️  REQUEST",
            "│ \(method) \(url.absoluteString)",
            "├─ Headers:"
        ]
        headers
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .forEach { lines.append("│    \($0.key.rawValue): \($0.value)") }
        if let body, let bodyString = String(data: body, encoding: .utf8) {
            lines.append("├─ Body:")
            lines.append("│    \(bodyString)")
        }
        lines.append("└─────────────────────────────────────────────────────────────")
        print(lines.joined(separator: "\n"))
    }

    /// Logs an incoming HTTP response (status, URL, and body).
    public static func logResponse(status: Int, url: URL, body: Data?) {
        guard shouldLog(url) else { return }

        var lines = [
            "",
            "┌─────────────────────────────────────────────────────────────",
            "│ [PayPal SDK] ⬅️  RESPONSE  •  status \(status)",
            "│ \(url.absoluteString)"
        ]
        if let body, let bodyString = String(data: body, encoding: .utf8) {
            lines.append("├─ Body:")
            lines.append("│    \(bodyString)")
        }
        lines.append("└─────────────────────────────────────────────────────────────")
        print(lines.joined(separator: "\n"))
    }

    // MARK: - Constructed URLs

    /// Logs a URL the SDK constructed (app-switch or web-fallback), with the optional `base` it derived from.
    public static func logURL(_ label: String, base: String? = nil, result: URL?) {
        guard isEnabled else { return }

        var lines = [
            "",
            "╔═══════════════════════════════════════════════════════════════",
            "║ \(label)"
        ]
        if let base {
            lines.append("║ ── base   : \(base)")
        }
        lines.append("║ ── result : \(result?.absoluteString ?? "nil")")
        lines.append("╚═══════════════════════════════════════════════════════════════")
        print(lines.joined(separator: "\n"))
    }

    // MARK: - Private

    private static func shouldLog(_ url: URL) -> Bool {
        guard isEnabled else { return false }
        return !excludedURLFragments.contains { url.absoluteString.contains($0) }
    }
}
