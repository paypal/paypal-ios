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

        /// 1. No return URL
        case noReturnUrl

        /// 2. Error returned from the PayPal Checkout SDK
        case payPalCheckoutError
    }

    static let unknown = PayPalSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown error has occured."
    )

    static let noReturnUrl = PayPalSDKError(
        code: Code.noReturnUrl.rawValue,
        domain: domain,
        errorDescription: "You need to provide a return URL in the config object to checkout with PayPal."
    )

    static let payPalCheckoutError: (ErrorInfo) -> PayPalSDKError = { errorInfo in
        PayPalSDKError(
            code: PayPalError.Code.payPalCheckoutError.rawValue,
            domain: PayPalError.domain,
            errorDescription: errorInfo.reason
        )
    }
}
