import Foundation

public struct PayPalSDKError: Error, LocalizedError {

    // TODO: - This follows the standard set by NSError, but do we need to? Maybe a string `Reason` or `Type`?
    /// The error code.
    public let code: Int?

    /// A string containing the error domain.
    public let domain: String?

    /// A string containing the localized description of the error.
    public let errorDescription: String?
}
