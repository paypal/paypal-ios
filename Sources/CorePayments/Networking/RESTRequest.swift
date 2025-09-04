import Foundation

@_documentation(visibility: private)
public enum ContentType {
    case json
    case formURLEncoded
    
    var headerValue: String {
        switch self {
        case .json:
            return "application/json"
        case .formURLEncoded:
            return "application/x-www-form-urlencoded"
        }
    }
}

@_documentation(visibility: private)
public struct RESTRequest {
    
    var path: String
    var method: HTTPMethod
    var queryParameters: [String: String]?
    var postParameters: Encodable?
    var contentType: ContentType
    
    public init(
        path: String,
        method: HTTPMethod,
        queryParameters: [String: String]? = nil,
        postParameters: Encodable? = nil,
        contentType: ContentType = .json
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.postParameters = postParameters
        self.contentType = contentType
    }
}
