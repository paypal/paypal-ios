@_implementationOnly import PayPalCheckout

#if canImport(PaymentsCore)
import PaymentsCore
#endif

enum PayPalError {

    static let domain = "PayPalErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. Error returned from the PayPal Checkout SDK
        case nativeCheckoutSDKError
    }

    static let nativeCheckoutSDKError: (ErrorInfo) -> PayPalSDKError = { errorInfo in
        PayPalSDKError(
            code: Code.nativeCheckoutSDKError.rawValue,
            domain: domain,
            errorDescription: errorInfo.reason
        )
    }
}
