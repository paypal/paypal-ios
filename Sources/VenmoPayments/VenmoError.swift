import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

/// Errors specific to the VenmoPayments module.
public enum VenmoError {

    static let domain = "VenmoClientErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. Error constructing the Venmo checkout URL.
        case venmoURLError

        /// 2. The result did not contain the expected data.
        case malformedResultError

        /// 3. The user canceled the Venmo checkout.
        case checkoutCanceledError

        /// 4. Venmo is not eligible as a funding source.
        case fundingEligibilityError
    }

    /// An error constructing the Venmo checkout URL.
    public static let venmoURLError = CoreSDKError(
        code: Code.venmoURLError.rawValue,
        domain: domain,
        errorDescription: "Error constructing URL for Venmo request."
    )

    /// The result did not contain the expected data.
    public static let malformedResultError = CoreSDKError(
        code: Code.malformedResultError.rawValue,
        domain: domain,
        errorDescription: "Result did not contain the expected data."
    )

    /// The user canceled the Venmo checkout.
    public static let checkoutCanceledError = CoreSDKError(
        code: Code.checkoutCanceledError.rawValue,
        domain: domain,
        errorDescription: "Venmo checkout has been canceled by the user"
    )

    /// Venmo is not eligible as a funding source for this transaction.
    public static let venmoNotEligible = CoreSDKError(
        code: Code.fundingEligibilityError.rawValue,
        domain: domain,
        errorDescription: "Venmo is not eligible as a funding source for this transaction."
    )

    /// An error occurred during the web authentication session.
    /// - Parameter error: The underlying error from the web session.
    /// - Returns: A `CoreSDKError` describing the web session failure.
    public static func webSessionError(_ error: Error) -> CoreSDKError {
        CoreSDKError(
            code: Code.unknown.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }

    /// Creates a funding eligibility error with a specific reason.
    /// - Parameter reason: The reason Venmo is not eligible.
    /// - Returns: A `CoreSDKError` describing the eligibility failure.
    public static func fundingEligibilityError(reason: String) -> CoreSDKError {
        CoreSDKError(
            code: Code.fundingEligibilityError.rawValue,
            domain: domain,
            errorDescription: "Venmo is not eligible as a funding source: \(reason)"
        )
    }

    /// Determines whether an error represents a Venmo checkout cancellation.
    /// - Parameter error: The error to check.
    /// - Returns: `true` if the error represents a user cancellation.
    public static func isCheckoutCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == VenmoError.domain && error.code == VenmoError.checkoutCanceledError.code
    }
}
