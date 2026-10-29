import Foundation

struct VenmoPaymentState: Equatable {

    struct ApprovalResult: Decodable, Equatable {

        let id: String
        let payerID: String
    }

    var createOrder: Order?
    var approveResult: ApprovalResult?
    var completedOrder: Order?

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

    var completedOrderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = completedOrderResponse {
                completedOrder = value
            }
        }
    }
}
