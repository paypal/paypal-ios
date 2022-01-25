import Foundation

enum APIClientError {

    static let domain = "APIClientErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occured.
        case unknown

        /// 1. Error returned from URLSession while making request.
        case urlSessionError

        /// 2. Error parsing HTTP response data.
        case dataParsingError

        /// 3. Invalid HTTPURLResponse from network.
        case invalidURLResponse

        /// 4. Missing HTTP response data.
        case noResponseData

        /// 5. There was an error constructing the URLRequest.
        case invalidURLRequest

        /// 6. The server's response body returned an error message.
        case serverResponseError
    }

    static let unknownError = CoreSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown error occured. Contact developer.paypal.com/support."
    )

    static let urlSessionError: (String) -> CoreSDKError = { description in
        CoreSDKError(
            code: Code.urlSessionError.rawValue,
            domain: domain,
            errorDescription: description
        )
    }

    static let dataParsingError = CoreSDKError(
        code: Code.dataParsingError.rawValue,
        domain: domain,
        errorDescription: "An error occured parsing HTTP response data. Contact developer.paypal.com/support."
    )

    static let invalidURLResponseError = CoreSDKError(
        code: Code.invalidURLResponse.rawValue,
        domain: domain,
        errorDescription: "An error occured due to an invalid HTTP response. Contact developer.paypal.com/support."
    )

    static let noResponseDataError = CoreSDKError(
        code: Code.noResponseData.rawValue,
        domain: domain,
        errorDescription: "An error occured due to missing HTTP response data. Contact developer.paypal.com/support."
    )

    static let invalidURLRequestError = CoreSDKError(
        code: Code.invalidURLRequest.rawValue,
        domain: domain,
        errorDescription: "An error occured constructing an HTTP request. Contact developer.paypal.com/support."
    )

    static let serverResponseError: (String) -> CoreSDKError = { description in
        CoreSDKError(
            code: Code.serverResponseError.rawValue,
            domain: domain,
            errorDescription: description
        )
    }
}
