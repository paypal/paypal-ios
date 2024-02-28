import Foundation
import CardPayments
import PayPalWebPayments

struct UpdateSetupTokenResult: Decodable, Equatable {

    var id: String
    var status: String?
    var didAttemptThreeDSecureAuthentication: Bool
}

struct VaultState: Equatable {

    var setupToken: CreateSetupTokenResponse?
    var paymentToken: PaymentTokenResponse?
    // result for card vault
    var updateSetupToken: UpdateSetupTokenResult?
    // result for paypal vault
    var paypalVaultToken: PayPalVaultResult?

    var setupTokenResponse: LoadingState<CreateSetupTokenResponse> = .idle {
        didSet {
            if case .loaded(let value) = setupTokenResponse {
                setupToken = value
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

    // response from Card Vault
    var updateSetupTokenResponse: LoadingState<UpdateSetupTokenResult> = .idle {
        didSet {
            if case .loaded(let value) = updateSetupTokenResponse {
                updateSetupToken = value
            }
        }
    }
    
    // response from PayPal Vault
    var paypalVaultTokenResponse: LoadingState<PayPalVaultResult> = .idle {
        didSet {
            if case .loaded(let value) = paypalVaultTokenResponse {
                paypalVaultToken = value
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
