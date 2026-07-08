import Foundation

@_documentation(visibility: private)
public struct HTTPResponseTiming: Equatable {

    public let startTime: Int64
    public let endTime: Int64

    public init(startTime: Int64, endTime: Int64) {
        self.startTime = startTime
        self.endTime = endTime
    }

    public static func epochMilliseconds() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
}
