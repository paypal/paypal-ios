import Foundation
import CardPayments

struct CardVaultState: Equatable {

    struct UpdateSetupTokenResult: Decodable, Equatable {

        var id: String
        var status: String
    }

    var setupToken: SetUpTokenResponse?
    var updateSetupToken: UpdateSetupTokenResult?
    var paymentToken: PaymentTokenResponse?
    var createdOrder: Order?
    var authorizedOrder: Order?
    var capturedOrder: Order?
    var intent: String = "AUTHORIZE"

    var setupTokenResponse: LoadingState<SetUpTokenResponse> = .idle {
        didSet {
            if case .loaded(let value) = setupTokenResponse {
                setupToken = value
            }
        }
    }

    var updateSetupTokenResponse: LoadingState<UpdateSetupTokenResult> = .idle {
        didSet {
            if case .loaded(let value) = updateSetupTokenResponse {
                updateSetupToken = value
            }
        }
    }

    var paymentTokenResponse: LoadingState<PaymentTokenResponse> = .idle {
        didSet {
            if case .loaded(let value) = paymentTokenResponse {
                paymentToken = value
            }
        }
    }

    var createdOrderResponse: LoadingState<Order> = .idle {
        didSet {
            if case .loaded(let value) = createdOrderResponse {
                createdOrder = value
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

enum LoadingState<T: Decodable & Equatable>: Equatable {

    case idle
    case loading
    case error(message: String)
    case loaded(_ value: T)
}
