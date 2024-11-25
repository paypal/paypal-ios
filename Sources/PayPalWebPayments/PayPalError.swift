import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

public enum PayPalError {

    static let domain = "PayPalClientErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. An error occurred during web authentication session.
        case webSessionError

        /// 2. Error constructing PayPal URL.
        case payPalURLError

        /// 3. Result did not contain the expected data.
        case malformedResultError

        /// 4. Vault result did not return a token id
        case payPalVaultResponseError

        /// 5. Checkout websession is cancelled by the user
        case checkoutCanceledError

        /// 6. Vault websession is cancelled by the user
        case vaultCanceledError
    }

    public static let webSessionError: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.webSessionError.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }

    public static let payPalURLError = CoreSDKError(
        code: Code.payPalURLError.rawValue,
        domain: domain,
        errorDescription: "Error constructing URL for PayPal request."
    )

    public static let malformedResultError = CoreSDKError(
        code: Code.malformedResultError.rawValue,
        domain: domain,
        errorDescription: "Result did not contain the expected data."
    )

    public static let payPalVaultResponseError = CoreSDKError(
        code: Code.payPalVaultResponseError.rawValue,
        domain: domain,
        errorDescription: "Error parsing PayPal vault response"
    )

    public static let checkoutCanceledError = CoreSDKError(
        code: Code.checkoutCanceledError.rawValue,
        domain: domain,
        errorDescription: "PayPal checkout has been canceled by the user"
    )

    public static let vaultCanceledError = CoreSDKError(
        code: Code.vaultCanceledError.rawValue,
        domain: domain,
        errorDescription: "PayPal vault has been canceled by the user"
    )

    // Helper function that allows handling of PayPal checkout cancel errors separately without having to cast the error to CoreSDKError and checking code and domain properties.
    public static func isCheckoutCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == PayPalError.domain && error.code == PayPalError.checkoutCanceledError.code
    }

    // Helper function that allows handling of PayPal vault cancel errors separately without having to cast the error to CoreSDKError and checking code and domain properties.
    public static func isVaultCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == PayPalError.domain && error.code == PayPalError.vaultCanceledError.code
    }
}
