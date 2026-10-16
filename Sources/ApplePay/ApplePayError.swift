import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

/// Errors produced while presenting Apple Pay and confirming the PayPal order.
public enum ApplePayError {

    static let domain = "ApplePayClientErrorDomain"

    enum Code: Int {
        case unknown
        case notEligible
        case unavailable
        case canceled
        case presentationFailed
        case invalidToken
        case confirmationFailed
        case noSupportedNetworks
    }

    public static let unknown = CoreSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown Apple Pay error occurred. Contact developer.paypal.com/support."
    )

    public static let notEligible = CoreSDKError(
        code: Code.notEligible.rawValue,
        domain: domain,
        errorDescription: "This PayPal merchant is not eligible for Apple Pay."
    )

    public static let unavailable = CoreSDKError(
        code: Code.unavailable.rawValue,
        domain: domain,
        errorDescription: "This device cannot make Apple Pay payments for the merchant's supported card networks."
    )

    public static let canceled = CoreSDKError(
        code: Code.canceled.rawValue,
        domain: domain,
        errorDescription: "The buyer canceled Apple Pay."
    )

    public static let presentationFailed = CoreSDKError(
        code: Code.presentationFailed.rawValue,
        domain: domain,
        errorDescription: "The Apple Pay sheet could not be presented. Check the Apple Pay entitlement and merchant ID."
    )

    public static let invalidToken = CoreSDKError(
        code: Code.invalidToken.rawValue,
        domain: domain,
        errorDescription: "Apple Pay returned a payment token that could not be read."
    )

    public static let noSupportedNetworks = CoreSDKError(
        code: Code.noSupportedNetworks.rawValue,
        domain: domain,
        errorDescription: "PayPal did not return any card networks supported by Apple Pay on this device."
    )

    public static func confirmationFailed(_ message: String) -> CoreSDKError {
        CoreSDKError(
            code: Code.confirmationFailed.rawValue,
            domain: domain,
            errorDescription: message
        )
    }

    /// `true` when the buyer dismissed the Apple Pay sheet.
    public static func isCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == domain && error.code == Code.canceled.rawValue
    }
}
