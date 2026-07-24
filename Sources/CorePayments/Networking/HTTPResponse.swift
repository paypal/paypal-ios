import Foundation

@_documentation(visibility: private)
public struct HTTPResponse {
    
    let status: Int
    let body: Data?

    let url: URL?

    init(status: Int, body: Data?, url: URL? = nil) {
        self.status = status
        self.body = body
        self.url = url
    }

    var isSuccessful: Bool { (200..<300).contains(status) }
}
