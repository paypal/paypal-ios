
import UIKit

public struct APIRequest {
    
    public var method: HTTPMethod
    public var path: String
    public var body: APIRequestBody?
    
    public init(method: HTTPMethod, path: String, body: APIRequestBody? = nil) {
        self.method = method
        self.path = path
        self.body = body
    }
}
