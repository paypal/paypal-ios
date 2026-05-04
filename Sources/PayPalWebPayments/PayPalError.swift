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
        case webSession

        /// 2. Error constructing PayPal URL.
        case payPalURL

        /// 3. Result did not contain the expected data.
        case malformedResult

        /// 4. Vault result did not return a token id
        case payPalVaultResponse

        /// 5. Checkout websession is cancelled by the user
        case checkoutCanceled

        /// 6. Vault websession is cancelled by the user
        case vaultCanceled
    }

    public static let webSession: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.webSession.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }

    public static let payPalURL = CoreSDKError(
        code: Code.payPalURL.rawValue,
        domain: domain,
        errorDescription: "Error constructing URL for PayPal request."
    )

    public static let malformedResult = CoreSDKError(
        code: Code.malformedResult.rawValue,
        domain: domain,
        errorDescription: "Result did not contain the expected data."
    )

    public static let payPalVaultResponse = CoreSDKError(
        code: Code.payPalVaultResponse.rawValue,
        domain: domain,
        errorDescription: "Error parsing PayPal vault response"
    )

    public static let checkoutCanceled = CoreSDKError(
        code: Code.checkoutCanceled.rawValue,
        domain: domain,
        errorDescription: "PayPal checkout has been canceled by the user"
    )

    public static let vaultCanceled = CoreSDKError(
        code: Code.vaultCanceled.rawValue,
        domain: domain,
        errorDescription: "PayPal vault has been canceled by the user"
    )

    // Helper function that allows handling of PayPal checkout cancel errors separately without having to cast the error to CoreSDKError and checking code and domain properties.
    public static func isCheckoutCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == PayPalError.domain && error.code == PayPalError.checkoutCanceled.code
    }

    // Helper function that allows handling of PayPal vault cancel errors separately without having to cast the error to CoreSDKError and checking code and domain properties.
    public static func isVaultCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == PayPalError.domain && error.code == PayPalError.vaultCanceled.code
    }
}
