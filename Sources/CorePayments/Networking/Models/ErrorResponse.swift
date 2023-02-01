import Foundation

struct ErrorResponse: Codable {

    let name: String
    let message: String?

    var readableDescription: String {
        if let message = message {
            return name + ": " + message
        } else {
            return name
        }
    }
}
