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
        
        /// 2. Error returned from the ClientID service
        case clientIDNotFoundError
    }
    
    static let nativeCheckoutSDKError: (PayPalCheckoutErrorInfo) -> CoreSDKError = { errorInfo in
        CoreSDKError(
            code: Code.nativeCheckoutSDKError.rawValue,
            domain: domain,
            errorDescription: errorInfo.reason
        )
    }
    
    static let clientIDNotFoundError: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.clientIDNotFoundError.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }
}
