import Foundation

public struct RESTRequest {
    
    var path: String
    var method: HTTPMethod
    var headers: [HTTPHeader: String]
    var queryParameters: [String: String]?
    var body: Data?
    
    public init(
        path: String,
        method: HTTPMethod,
        headers: [HTTPHeader : String],
        queryParameters: [String : String]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.body = body
    }
}
