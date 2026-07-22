import Foundation

@_documentation(visibility: private)
public struct HTTPResponse {

    /// Wall-clock timing captured around the underlying `URLSession` network call.
    /// Used to report API request latency via analytics.
    public struct Timing {

        /// Epoch milliseconds captured immediately before the `URLSession` call.
        public let startTime: Int64

        /// Epoch milliseconds captured immediately after the response is received.
        public let endTime: Int64

        public init(startTime: Int64, endTime: Int64) {
            self.startTime = startTime
            self.endTime = endTime
        }
    }

    let status: Int
    let body: Data?

    let url: URL?

    /// Timing of the underlying network call, when captured by `HTTP`.
    public let timing: Timing?

    init(status: Int, body: Data?, url: URL? = nil, timing: Timing? = nil) {
        self.status = status
        self.body = body
        self.url = url
        self.timing = timing
    }

    var isSuccessful: Bool { (200..<300).contains(status) }
}
