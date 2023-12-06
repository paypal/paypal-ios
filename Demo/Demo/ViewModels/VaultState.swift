import Foundation
import CardPayments

struct VaultState: Equatable {

    struct UpdateSetupTokenResult: Decodable, Equatable {

        var id: String
        var status: String
    }

    var setupToken: SetUpTokenResponse?
    var updateSetupToken: UpdateSetupTokenResult?
    var paymentToken: PaymentTokenResponse?
    var paypalVaultToken: String?

    var setupTokenResponse: LoadingState<SetUpTokenResponse> = .idle {
        didSet {
            if case .loaded(let value) = setupTokenResponse {
                setupToken = value
            }
        }
    }

    var paypalVaultTokenResponse: LoadingState<String> = .idle {
        didSet {
            if case .loaded(let value) = paypalVaultTokenResponse {
                paypalVaultToken = value
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
}

enum LoadingState<T: Decodable & Equatable>: Equatable {

    case idle
    case loading
    case error(message: String)
    case loaded(_ value: T)
}
