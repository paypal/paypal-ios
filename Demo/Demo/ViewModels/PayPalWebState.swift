import Foundation
import PayPalWebPayments

struct PayPalWebState: Equatable {

    struct CheckoutResult: Decodable, Equatable {

        let id: String
        let payerID: String
    }

    var order: Order?
    var intent: Intent = .authorize
    var checkoutResult: CheckoutResult?

    var orderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = orderResponse {
                order = value
            }
        }
    }

    var checkoutResultResponse: LoadingState<CheckoutResult> = .idle {
        didSet {
            if case .loaded(let value) = checkoutResultResponse {
                checkoutResult = value
            }
        }
    }
}
