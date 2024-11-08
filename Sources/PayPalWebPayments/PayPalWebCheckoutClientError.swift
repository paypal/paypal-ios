import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

enum PayPalWebCheckoutClientError {

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

        /// 5. Websession is cancelled by the user
        case payPalCancellationError

        /// 6. Websession is cancelled by the user
        case payPalVaultCancellationError
    }

    static let webSessionError: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.webSessionError.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }

    static let payPalURLError = CoreSDKError(
        code: Code.payPalURLError.rawValue,
        domain: domain,
        errorDescription: "Error constructing URL for PayPal request."
    )

    static let malformedResultError = CoreSDKError(
        code: Code.malformedResultError.rawValue,
        domain: domain,
        errorDescription: "Result did not contain the expected data."
    )

    static let payPalVaultResponseError = CoreSDKError(
        code: Code.payPalVaultResponseError.rawValue,
        domain: domain,
        errorDescription: "Error parsing PayPal vault response"
    )

    static let checkoutCanceled = CoreSDKError(
        code: Code.payPalCancellationError.rawValue,
        domain: domain,
        errorDescription: "PayPal checkout has been canceled by the user"
    )

    static let vaultCanceled = CoreSDKError(
        code: Code.payPalVaultCancellationError.rawValue,
        domain: domain,
        errorDescription: "PayPal vault has been canceled by the user"
    )
}
