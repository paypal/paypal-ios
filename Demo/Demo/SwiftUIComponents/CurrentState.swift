import Foundation

enum CurrentState: Equatable {

    case idle
    case loading
    case error(message: String)
    case loaded
}
