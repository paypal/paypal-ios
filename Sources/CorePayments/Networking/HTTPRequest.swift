import Foundation

/// :nodoc:
public struct HTTPRequest {
    
    let url: URL
    let method: HTTPMethod
    let body: Data?
    let headers: [HTTPHeader: String]
}
