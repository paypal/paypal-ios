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

struct PayPalPaymentState: Equatable {
    
    struct ApprovalResult: Decodable, Equatable {
        let id: String
        let status: String?

    }
    var createOrder: Order?
    var authorizedOrder: Order?
    var capturedOrder: Order?
    var intent: Intent = .authorize
    var approveResult: ApprovalResult?
    
    var createdOrderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = createdOrderResponse {
                createOrder = value
            }
        }
    }

    var approveResultResponse: LoadingState<ApprovalResult> = .idle {
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
