import Foundation

// TODO: Refine how we want to do error handling
/// For further reading, see https://developer.apple.com/documentation/swift/error
/// For Discussion:
/// Error conforming enum vs Error conforming Struct?
public enum CoreError: Error {
    case networkingError(Error)
    case decodingError(Error)
    case encodingError(Error)
    case noResponseData
    case noUrlRequest
    case unknown
}
