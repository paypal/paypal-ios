#if canImport(PaymentsCore)
import PaymentsCore
#endif

public enum PayPalError {

    static let domain = "PayPalErrorDomain"

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
}
