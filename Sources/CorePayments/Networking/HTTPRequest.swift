import Foundation

/// :nodoc:
public struct HTTPRequest {
    
    let url: URL
    let method: HTTPMethod
    let body: Data?
    let headers: [HTTPHeader: String]
    
    /// :nodoc:
    public init(
        url: URL,
        method: HTTPMethod,
        body: Data?,
        headers: [HTTPHeader: String]
    ) {
        self.url = url
        self.method = method
        self.body = body
        self.headers = headers
    }
}
