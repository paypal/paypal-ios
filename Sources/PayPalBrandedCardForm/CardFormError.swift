import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

public enum CardFormError {

    static let domain = "CardFormErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. An error occurred during web authentication session.
        case webSessionError

        /// 2. Error constructing PayPal URL.
        case payPalURLError

        /// 3. Result did not contain the expected data.
        case malformedResultError

        /// 4. Checkout websession is cancelled by the user
        case checkoutCanceledError
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

    public static let checkoutCanceledError = CoreSDKError(
        code: Code.checkoutCanceledError.rawValue,
        domain: domain,
        errorDescription: "PayPal checkout has been canceled by the user"
    )

    // Helper function that allows handling of PayPal checkout cancel errors separately without having to cast the error to CoreSDKError and checking code and domain properties.
    public static func isCheckoutCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == CardFormError.domain && error.code == CardFormError.checkoutCanceledError.code
    }
}
