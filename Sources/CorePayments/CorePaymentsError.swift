public enum CorePaymentsError {

    static let domain = "CorePaymentsErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occurred.
        case unknown

        /// 1. An error occured constructing the PayPal API URL
        case urlEncodingFailed
    }

    public static let urlEncodingFailed = CoreSDKError(
        code: Code.urlEncodingFailed.rawValue,
        domain: domain,
        errorDescription: "An error occured constructing the PayPal API URL. Contact developer.paypal.com/support."
    )
}
