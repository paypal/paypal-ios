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
        
        /// 3 . An invalid 3DS challenge URL was returned by `/confirm-payment-source`
        case threeDSecureURLError
    }

    static let unknownError = CoreSDKError(
        code: Code.encodingError.rawValue,
        domain: domain,
        errorDescription: "An unknown error has occured. Contact developer.paypal.com/support."
    )
    
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
    
    static let threeDSecureURLError = CoreSDKError(
        code: Code.threeDSecureURLError.rawValue,
        domain: domain,
        errorDescription: "An invalid 3DS URL was returned. Contact developer.paypal.com/support."
    )
}
