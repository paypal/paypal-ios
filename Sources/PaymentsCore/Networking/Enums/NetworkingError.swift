import Foundation

// TODO: Refine how we want to do error handling
/// For further reading, see https://developer.apple.com/documentation/swift/error
/// For Discussion:
/// Error conforming enum vs Error conforming Struct?
public enum NetworkingError: Error {
    case networkingError(Error)
    case decodingError(Error)
    case badURLResponse
    case noResponseData
    case noURLRequest
    case unknown

    //TODO: Write localized descriptions for each error case
}
