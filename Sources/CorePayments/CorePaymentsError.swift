public enum CorePaymentsError {

    static let domain = "CorePaymentsErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. Error returned from the ClientID service
        case clientIDNotFoundError
    }

    public static let clientIDNotFoundError = CoreSDKError(
        code: Code.clientIDNotFoundError.rawValue,
        domain: domain,
        errorDescription: "Error fetching clientID. Contact developer.paypal.com/support."
    )
}
