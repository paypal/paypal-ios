import Foundation


/// Request method associated with a URL request
/// For more information, see https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
/// Methods can be added here as they are needed
@_documentation(visibility: private)
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
