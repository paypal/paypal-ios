import Foundation
import PayPalWebPayments

struct PayPalWebState: Equatable {

    var order: Order?
    var intent: Intent = .authorize

    var orderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = orderResponse {
                order = value
            }
        }
    }
}
