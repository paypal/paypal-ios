import Foundation

/// :nodoc:
public struct HTTPRequest {
    
    let headers: [HTTPHeader: String]
    let method: HTTPMethod
    let url: URL
    let body: Data?

    /// :nodoc:
    public init(
        headers: [HTTPHeader: String],
        method: HTTPMethod,
        url: URL,
        body: Data?
    ) {
        self.headers = headers
        self.method = method
        self.url = url
        self.body = body
    }
}
