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
        case encoding

        /// 2. An error occurred during 3DS challenge.
        case threeDSecure

        /// 3 . An invalid 3DS challenge URL was returned by `/confirm-payment-source`
        case threeDSecureURL

        /// 4. No data was returned from updating setup token
        case vaultTokenDataMissing

        /// 5. An error occurred during updating setup token
        case vaultToken

        /// 6. GraphQLClient is unexpectedly nil
        case graphQLClientUnavailable

        /// 7. An error from 3DS verification
        case threeDSVerification

        /// 8. Missing Deeplink URL from 3DS
        case deeplinkURLMissing

        /// 9. Malformed Deeplink URL from 3DS
        case deeplinkURLMalformed

        /// 10. Cancellation from 3DS verification
        case threeDSecureCanceled
    }

    public static let unknown = CoreSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown error has occured. Contact developer.paypal.com/support."
    )

    public static let encoding = CoreSDKError(
        code: Code.encoding.rawValue,
        domain: domain,
        errorDescription: "An error occured encoding HTTP request body data. Contact developer.paypal.com/support."
    )

    public static let threeDSecure: (Error) -> CoreSDKError = { error in
        CoreSDKError(
            code: Code.threeDSecure.rawValue,
            domain: domain,
            errorDescription: error.localizedDescription
        )
    }

    public static let threeDSecureURL = CoreSDKError(
        code: Code.threeDSecureURL.rawValue,
        domain: domain,
        errorDescription: "An invalid 3DS URL was returned. Contact developer.paypal.com/support."
    )

    public static let threeDSecureCanceled = CoreSDKError(
        code: Code.threeDSecureCanceled.rawValue,
        domain: domain,
        errorDescription: "3DS verification has been canceled by the user."
    )

    public static let vaultTokenDataMissing = CoreSDKError(
        code: Code.vaultTokenDataMissing.rawValue,
        domain: domain,
        errorDescription: "No data was returned from update setup token service."
    )

    public static let vaultToken = CoreSDKError(
        code: Code.vaultToken.rawValue,
        domain: domain,
        errorDescription: "An error occurred while vaulting a card."
    )

    public static let graphQLClientUnavailable = CoreSDKError(
        code: Code.graphQLClientUnavailable.rawValue,
        domain: domain,
        errorDescription: "GraphQLClient is unexpectedly nil."
    )

    // Helper function that allows handling of threeDSecure websession cancel errors separately without having to check error code and domain properties.
    public static func isThreeDSecureCanceled(_ error: Error) -> Bool {
        guard let error = error as? CoreSDKError else {
            return false
        }
        return error.domain == CardError.domain && error.code == CardError.threeDSecureCanceled.code
    }
}
