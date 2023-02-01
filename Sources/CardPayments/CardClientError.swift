import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

enum CardClientError {

    static let domain = "CardClientErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. An error occurred encoding an HTTP request body.
        case encodingError

        /// 2. An error occurred during 3DS challenge.
        case threeDSecureError
    }

    static let encodingError = CoreSDKError(
        code: Code.encodingError.rawValue,
        domain: domain,
        errorDescription: "An error occured encoding HTTP request body data. Contact developer.paypal.com/support."
    )

    static let threeDSecureError: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.threeDSecureError.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }
}
