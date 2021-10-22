import Foundation
#if canImport(PaymentsCore)
import PaymentsCore
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

    static let noReturnUrl = PayPalSDKError(
        code: Code.noReturnUrl.rawValue,
        domain: domain,
        errorDescription: "You need to provide a return URL in the config object to checkout with PayPal."
    )
}
