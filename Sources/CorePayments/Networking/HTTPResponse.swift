import Foundation

@_documentation(visibility: private)
public struct HTTPResponse {
    
    let status: Int
    let body: Data?

    var isSuccessful: Bool { (200..<300).contains(status) }
}
