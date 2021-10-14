import Foundation

struct APIClientError {

    static let domain = "APIClientErrorDomain"

    enum Code: Int {
        /// 0. Unknown error.
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
    
    static let unknownError = PayPalSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "todo"
    )
    
    static let urlSessionError: (String) -> PayPalSDKError = { description in
        return PayPalSDKError(
            code: Code.urlSessionError.rawValue,
            domain: domain,
            errorDescription: description
        )
    }
    
    static let dataParsingError = PayPalSDKError(
        code: Code.dataParsingError.rawValue,
        domain: domain,
        errorDescription: "todo"
    )
    
    static let invalidURLResponseError = PayPalSDKError(
        code: Code.invalidURLResponse.rawValue,
        domain: domain,
        errorDescription: "todo"
    )
    
    static let noResponseDataError = PayPalSDKError(
        code: Code.noResponseData.rawValue,
        domain: domain,
        errorDescription: "todo"
    )
    
    static let invalidURLRequestError = PayPalSDKError(
        code: Code.invalidURLRequest.rawValue,
        domain: domain,
        errorDescription: "todo"
    )

    static let serverResponseError: (String) -> PayPalSDKError = { description in
        return PayPalSDKError(
            code: Code.serverResponseError.rawValue,
            domain: domain,
            errorDescription: description
        )
    }
}
