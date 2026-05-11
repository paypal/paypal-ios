import Foundation

@_documentation(visibility: private)
public enum NetworkingError {

    static let domain = "NetworkingClientErrorDomain"

    enum Code: Int {
        /// 0. An unknown error occured.
        case unknown

        /// 1. Error returned from URLSession while making request.
        case networkRequestFailed

        /// 2. An error occured decoding HTTP response data
        case jsonDecodingFailed

        /// 3. Invalid HTTPURLResponse from network.
        case invalidURLResponse

        /// 4. Missing HTTP response data.
        case responseDataMissing

        /// 5. There was an error constructing the URLRequest.
        case invalidURLRequest

        /// 6. The server's response body returned an error message.
        case serverErrorReceived

        /// 7. Missing expected GraphQL response data key.
        case graphQLDataKeyMissing
    }

    public static let unknown = CoreSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "An unknown error occured. Contact developer.paypal.com/support."
    )

    public static let networkRequestFailed = CoreSDKError(
        code: Code.networkRequestFailed.rawValue,
        domain: domain,
        errorDescription: "An error occured during network call. Contact developer.paypal.com/support."
    )

    public static let jsonDecodingFailed: (String) -> CoreSDKError = { description in
        CoreSDKError(
            code: Code.jsonDecodingFailed.rawValue,
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
        code: Code.responseDataMissing.rawValue,
        domain: domain,
        errorDescription: "An error occured due to missing HTTP response data. Contact developer.paypal.com/support."
    )

    public static let invalidURLRequest = CoreSDKError(
        code: Code.invalidURLRequest.rawValue,
        domain: domain,
        errorDescription: "An error occured constructing an HTTP request. Contact developer.paypal.com/support."
    )

    public static let serverErrorReceived: (String) -> CoreSDKError = { description in
        CoreSDKError(
            code: Code.serverErrorReceived.rawValue,
            domain: domain,
            errorDescription: description
        )
    }

    public static let graphQLDataKeyMissing = CoreSDKError(
        code: Code.graphQLDataKeyMissing.rawValue,
        domain: domain,
        errorDescription: "An error occured due to missing `data` key in GraphQL query response. Contact developer.paypal.com/support."
    )
}
