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

        /// 2. The buyer canceled the PayPal Checkout flow
        case cancelled
    }

    static let nativeCheckoutSDKError: (ErrorInfo) -> PayPalSDKError = { errorInfo in
        PayPalSDKError(
            code: Code.nativeCheckoutSDKError.rawValue,
            domain: domain,
            errorDescription: errorInfo.reason
        )
    }

    static let cancelled = PayPalSDKError(
        code: Code.cancelled.rawValue,
        domain: domain,
        errorDescription: "The buyer canceled the PayPal Checkout flow"
    )
}
