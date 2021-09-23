import Foundation

// TODO: Refine how we want to do error handling
/// For further reading, see https://developer.apple.com/documentation/swift/error
/// For Discussion:
/// Error conforming enum vs Error conforming Struct?
public enum CoreError: Error {
    case encodingError(Error)
    case unknown

    // TODO: Write localized descriptions for each error case
}
