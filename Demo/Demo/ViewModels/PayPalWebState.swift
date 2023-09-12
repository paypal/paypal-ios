import Foundation
import PayPalWebPayments

struct PayPalWebState: Equatable {

    struct CheckoutResult: Decodable, Equatable {

        let id: String
        let payerID: String
    }

    var createOrder: Order?
    var intent: Intent = .authorize
    var checkoutResult: CheckoutResult?

    var createdOrderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = createdOrderResponse {
                createOrder = value
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
