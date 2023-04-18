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
        
        /// 2. An error occured fetching details for this Order ID
        case getOrderDetailsError
    }

    static let nativeCheckoutSDKError: (String) -> CoreSDKError = { description in
        CoreSDKError(
            code: Code.nativeCheckoutSDKError.rawValue,
            domain: domain,
            errorDescription: description
        )
    }
}
