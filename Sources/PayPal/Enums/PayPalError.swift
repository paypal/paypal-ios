#if canImport(PaymentsCore)
import PaymentsCore
#endif

#if canImport(PayPalCheckout)
import PayPalCheckout
#endif

enum PayPalError {

    static let domain = "PayPalErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. Error returned from the PayPal Checkout SDK
        case payPalCheckoutError
    }

    static let unknown = PayPalSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown error has occured."
    )

    static let payPalCheckoutError: (ErrorInfo) -> PayPalSDKError = { errorInfo in
        PayPalSDKError(
            code: Code.payPalCheckoutError.rawValue,
            domain: domain,
            errorDescription: errorInfo.reason
        )
    }
}
