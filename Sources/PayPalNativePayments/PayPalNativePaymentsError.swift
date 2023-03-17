#if canImport(CorePayments)
import CorePayments
#endif

enum PayPalNativePaymentsError {

    static let domain = "PayPalErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. Error returned from the PayPal Checkout SDK
        case nativeCheckoutSDKError
    }

    static let nativeCheckoutSDKError: (String) -> CoreSDKError = { description in
        CoreSDKError(
            code: Code.nativeCheckoutSDKError.rawValue,
            domain: domain,
            errorDescription: description
        )
    }
}
