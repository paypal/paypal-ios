import Foundation
import CardPayments

struct CardVaultState {

    struct UpdateSetupTokenResult {

        var id: String
        var status: String
    }

    var setupTokenResponse: SetUpTokenResponse?
    var updateSetupToken: UpdateSetupTokenResult?
    var paymentTokenResponse: PaymentTokenResponse?
}
