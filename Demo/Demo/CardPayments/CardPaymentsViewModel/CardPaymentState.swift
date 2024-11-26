import Foundation
import CardPayments

struct CardPaymentState: Equatable {

    struct CardResult: Decodable, Equatable {

        let id: String
        let status: String?
        let didAttemptThreeDSecureAuthentication: Bool
    }

    var createOrder: Order?
    var authorizedOrder: Order?
    var capturedOrder: Order?
    var intent: Intent = .authorize
    var scaSelection: SCA = .scaWhenRequired
    var approveResult: CardResult?

    var createdOrderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = createdOrderResponse {
                createOrder = value
            }
        }
    }

    var approveResultResponse: LoadingState<CardResult> = .idle {
        didSet {
            if case .loaded(let value) = approveResultResponse {
                approveResult = value
            }
        }
    }

    var capturedOrderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = capturedOrderResponse {
                capturedOrder = value
            }
        }
    }

    var authorizedOrderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = authorizedOrderResponse {
                authorizedOrder = value
            }
        }
    }
}
