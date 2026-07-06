import SwiftUI

enum PaymentType {
    case paypal
    case card
}

@MainActor
class VaultViewModel: ObservableObject {

    @Published var state = VaultState()

    // TODO: Replace with PayPalUserAction/PayPalUserIdentity from SDK when feature/shopper-session-id merges
    @Published var selectedUserAction: UserActionSelection = .payNow
    @Published var selectedUserIdentity: UserIdentitySelection = .none
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var userSSID: String = ""

    func getSetupToken(
        customerID: String? = nil,
        selectedMerchantIntegration: MerchantIntegration,
        paymentType: PaymentType,
        sca: String = "SCA_WHEN_REQUIRED"
    ) async throws {
        do {
            DispatchQueue.main.async {
                self.state.setupTokenResponse = .loading
            }

            let experienceContext = VaultExperienceContext()

            var paymentSourceType: PaymentSourceType
            switch paymentType {
            case .card:
                paymentSourceType = PaymentSourceType.card(verification: sca, experienceContext: experienceContext)
            case .paypal:
                paymentSourceType = PaymentSourceType.paypal(usageType: "MERCHANT", experienceContext: experienceContext)
            }

            let setupTokenResult = try await DemoMerchantAPI.sharedService.createSetupToken(
                customerID: customerID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                paymentSourceType: paymentSourceType
            )
            DispatchQueue.main.async {
                self.state.setupTokenResponse = .loaded(setupTokenResult)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.setupTokenResponse = .error(message: error.localizedDescription)
            }
            throw error
        }
    }

    func resetState() {
        state = VaultState()
        selectedUserAction = .payNow
        selectedUserIdentity = .none
        userEmail = ""
        userPhone = ""
        userSSID = ""
    }

    func getPaymentToken(
        setupToken: String,
        selectedMerchantIntegration: MerchantIntegration
    ) async throws {
        do {
            DispatchQueue.main.async {
                self.state.paymentTokenResponse = .loading
            }
            let paymentTokenResult = try await DemoMerchantAPI.sharedService.createPaymentToken(
                setupToken: setupToken,
                selectedMerchantIntegration: selectedMerchantIntegration
            )
            DispatchQueue.main.async {
                self.state.paymentTokenResponse = .loaded(paymentTokenResult)
            }
        } catch {
            DispatchQueue.main.async {
                self.state.paymentTokenResponse = .error(message: error.localizedDescription)
            }
            throw error
        }
    }
}
