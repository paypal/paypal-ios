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
    }
    
    static let webSessionError: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.webSessionError.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }
}
