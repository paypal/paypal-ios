import Foundation

// TODO: Refine how we want to do error handling
/// For further reading, see https://developer.apple.com/documentation/swift/error
/// For Discussion:
/// Error conforming enum vs Error conforming Struct?
public enum NetworkingError: Error {

    case connectionIssue(Error)
    case parsingError(Error)
    case invalidURLResponse
    case noResponseData
    case noURLRequest
    case unknown

    // TODO: Write localized descriptions for each error case
    // TODO: Should make error cases easier to compare - conforming to Equatable and adding errorCode?
}
