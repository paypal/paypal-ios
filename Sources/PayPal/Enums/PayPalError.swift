#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
@_implementationOnly import PayPalCheckout
#endif

enum PayPalError {

    static let domain = "PayPalErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. Error returned from the PayPal Checkout SDK
        case payPalCheckoutError
    }

    static let payPalCheckoutError: (ErrorInfo) -> PayPalSDKError = { errorInfo in
        PayPalSDKError(
            code: Code.payPalCheckoutError.rawValue,
            domain: domain,
            errorDescription: errorInfo.reason
        )
    }
}
