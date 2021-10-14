import Foundation

struct APIClientError {

    static let domain = "APIClientErrorDomain"

    enum Code: Int {
        /// 0. Unknown error.
        case unknown
        
        /// 1. Error returned from URLSession while making request
        case urlSessionError
        
        /// 2. Error parsing HTTP response data.
        case dataParsingError
        
        /// 3. Invalid HTTPURLResponse from network.
        case invalidURLResponse
        
        /// 4. Missing HTTP response data.
        case noResponseData
        
        /// 5. There was an error constructing the URLRequest.
        case invalidURLRequest

        /// 6. The request response returned an error message
        case networkingResponseError
    }
    
    static let urlSessionError = (String) -> PayPalSDKError = { description in
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
    
    // TODO: - do we need this
    static let unknownError = PayPalSDKError(
        code: Code.unknown.rawValue,
        domain: domain,
        errorDescription: "todo"
    )

    static let responseError: (String) -> PayPalSDKError = { description in
        return PayPalSDKError(
            code: Code.networkingResponseError.rawValue,
            domain: "Response Error" ,
            errorDescription: description
        )
    }


    // NOTE: Maybe it is OK if the errorDescription is sometimes bubbled up from the raw API?
    // Let's do some manual tests. Do we have Card #s that we can trigger an error response from
    // using orders/v2?
    
}
