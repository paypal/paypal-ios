import Foundation

public enum CoreError: Error {
    case encodingError(Error)
    case unknown

    // TODO: Write localized descriptions for each error case
}
