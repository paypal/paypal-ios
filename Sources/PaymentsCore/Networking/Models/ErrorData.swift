import Foundation

struct ErrorData: Codable {
    let name: String
    let message: String

    var readableDescription: String {
        return name + ": " + message
    }
}
