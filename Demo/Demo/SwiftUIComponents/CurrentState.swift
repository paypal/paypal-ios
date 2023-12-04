import Foundation

enum CurrentState: Equatable {
    case idle
    case loading
    case orderSuccess
    case orderApproved
    case transactionSuccess
    case error(message: String)
}
