import Foundation

/// :nodoc:
public struct RESTRequest {
    
    var path: String
    var method: HTTPMethod
    var queryParameters: [String: String]?
    var body: Data?
    
    public init(
        path: String,
        method: HTTPMethod,
        queryParameters: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.body = body
    }
}
