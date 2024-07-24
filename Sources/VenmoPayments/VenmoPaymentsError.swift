import Foundation

#if canImport(CorePayments)
import CorePayments
#endif

enum VenmoPaymentsError {
    
    static let domain = "VenmoPaymentsErrorDomain"
    
    enum Code: Int {
        /// 0. An unknown error has occurred.
        case unknown
        
        // TODO: Add venmo specific errors at a later time, in a future PR
    }
    
    static let unknownError = CoreSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown error has occurred. Contact developer.paypal.com/support."
    )
}
