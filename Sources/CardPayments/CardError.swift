import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

public enum CardError {

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
        
        /// 4. No data was returned from updating setup token
        case noVaultTokenDataError
        
        /// 5. An error occurred during updating setup token
        case vaultTokenError

        /// 6. GraphQLClient is unexpectedly nil
        case nilGraphQLClientError
        
        /// 7. An error from 3DS verification
        case threeDSVerificationError
        
        /// 8. Missing Deeplink URL from 3DS
        case missingDeeplinkURLError
        
        /// 9. Malformed Deeplink URL from 3DS
        case malformedDeeplinkURLError

        /// 10. Cancellation from 3DS verification
        case threeDSecureCanceledError
    }

    public static let unknownError = CoreSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown error has occured. Contact developer.paypal.com/support."
    )
    
    public static let encodingError = CoreSDKError(
        code: Code.encodingError.rawValue,
        domain: domain,
        errorDescription: "An error occured encoding HTTP request body data. Contact developer.paypal.com/support."
    )

    public static let threeDSecureError: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.threeDSecureError.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }
    
    public static let threeDSecureURLError = CoreSDKError(
        code: Code.threeDSecureURLError.rawValue,
        domain: domain,
        errorDescription: "An invalid 3DS URL was returned. Contact developer.paypal.com/support."
    )

    public static let threeDSecureCanceledError = CoreSDKError(
        code: Code.threeDSecureCanceledError.rawValue,
        domain: domain,
        errorDescription: "3DS verification has been canceled by the user."
    )

    public static let noVaultTokenDataError = CoreSDKError(
        code: Code.noVaultTokenDataError.rawValue,
        domain: domain,
        errorDescription: "No data was returned from update setup token service."
    )
    
    public static let vaultTokenError = CoreSDKError(
        code: Code.vaultTokenError.rawValue,
        domain: domain,
        errorDescription: "An error occurred while vaulting a card."
    )

    public static let nilGraphQLClientError = CoreSDKError(
        code: Code.nilGraphQLClientError.rawValue,
        domain: domain,
        errorDescription: "GraphQLClient is unexpectedly nil."
    )

    // Helper function that allows handling of threeDSecure websession cancel errors separately without having to check error code and domain properties.
    public static func isThreeDSecureCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == CardError.domain && error.code == CardError.threeDSecureCanceledError.code
    }
}
