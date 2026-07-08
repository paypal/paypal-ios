import Foundation

@_documentation(visibility: private)
public struct HTTPResponse {

    let status: Int
    let body: Data?
    let timing: HTTPResponseTiming?

    init(status: Int, body: Data?, timing: HTTPResponseTiming? = nil) {
        self.status = status
        self.body = body
        self.timing = timing
    }

    var isSuccessful: Bool { (200..<300).contains(status) }
}
