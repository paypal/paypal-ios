import Foundation

#if canImport(PaymentsCore)
import PaymentsCore
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
    }

    static let webSessionError: (Error) -> PayPalSDKError = { error in
        PayPalSDKError(
            code: Code.webSessionError.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }

    static let payPalURLError = PayPalSDKError(
        code: Code.payPalURLError.rawValue,
        domain: domain,
        errorDescription: "Error constructing URL for PayPal request."
    )

    static let malformedResultError = PayPalSDKError(
        code: Code.malformedResultError.rawValue,
        domain: domain,
        errorDescription: "Result did not contain the expected data."
    )
}
