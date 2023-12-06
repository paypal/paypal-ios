import Foundation

enum CurrentState: Equatable {
    case idle
    case loading
    case success
    case error(message: String)
}
