import Foundation

enum CurrentState: Equatable {
    case idle
    case loading
    case loaded
    case success
    case error(message: String)
}
