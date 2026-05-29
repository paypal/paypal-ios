import Foundation

struct VenmoPaymentState: Equatable {

    struct ApprovalResult: Decodable, Equatable {

        let id: String
        let status: String?
    }

    var createOrder: Order?
    var capturedOrder: Order?
    var intent: Intent = .capture
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
}
