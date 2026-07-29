import Foundation

@_documentation(visibility: private)
public struct HTTPResponse {

    public struct Timing {

        public let startTime: Int64

        public let endTime: Int64

        public init(startTime: Int64, endTime: Int64) {
            self.startTime = startTime
            self.endTime = endTime
        }
    }

    let status: Int
    let body: Data?

    let url: URL?

    public let timing: Timing?

    init(status: Int, body: Data?, url: URL? = nil, timing: Timing? = nil) {
        self.status = status
        self.body = body
        self.url = url
        self.timing = timing
    }

    var isSuccessful: Bool { (200..<300).contains(status) }
}
