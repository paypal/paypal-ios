import Foundation

@_documentation(visibility: private)
public enum NetworkingError {

    static let domain = "NetworkingClientErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occured.
        case unknown

        /// 1. Error returned from URLSession while making request.
        case urlSession

        /// 2. An error occured decoding HTTP response data
        case jsonDecoding

        /// 3. Invalid HTTPURLResponse from network.
        case invalidURLResponse

        /// 4. Missing HTTP response data.
        case noResponseData

        /// 5. There was an error constructing the URLRequest.
        case invalidURLRequest

        /// 6. The server's response body returned an error message.
        case serverResponse

        /// 7. Missing expected GraphQL response data key.
        case noGraphQLDataKey
    }

    public static let unknown = CoreSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown error occured. Contact developer.paypal.com/support."
    )

    public static let urlSession = CoreSDKError(
        code: Code.urlSession.rawValue,
        domain: domain,
        errorDescription: "An error occured during network call. Contact developer.paypal.com/support."
    )

    public static let jsonDecoding: (String) -> CoreSDKError = { description in
        CoreSDKError(
            code: Code.jsonDecoding.rawValue,
            domain: domain,
            errorDescription: description
        )
    }

    public static let invalidURLResponse = CoreSDKError(
        code: Code.invalidURLResponse.rawValue,
        domain: domain,
        errorDescription: "An error occured due to an invalid HTTP response. Contact developer.paypal.com/support."
    )

    public static let responseDataMissing = CoreSDKError(
        code: Code.noResponseData.rawValue,
        domain: domain,
        errorDescription: "An error occured due to missing HTTP response data. Contact developer.paypal.com/support."
    )

    public static let invalidURLRequest = CoreSDKError(
        code: Code.invalidURLRequest.rawValue,
        domain: domain,
        errorDescription: "An error occured constructing an HTTP request. Contact developer.paypal.com/support."
    )

    public static let serverResponse: (String) -> CoreSDKError = { description in
        CoreSDKError(
            code: Code.serverResponse.rawValue,
            domain: domain,
            errorDescription: description
        )
    }

    public static let noGraphQLDataKey = CoreSDKError(
        code: Code.noGraphQLDataKey.rawValue,
        domain: domain,
        errorDescription: "An error occured due to missing `data` key in GraphQL query response. Contact developer.paypal.com/support."
    )
}
