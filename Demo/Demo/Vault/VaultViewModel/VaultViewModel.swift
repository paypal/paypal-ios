import SwiftUI
import PayPalPayments

enum PaymentType {
    case paypal
    case card
}

@MainActor
class VaultViewModel: ObservableObject {

    @Published var state = VaultState()

    @Published var selectedUserAction: PayPalUserAction = .setupNow
    @Published var selectedUserIdentity: UserIdentitySelection = .none
    @Published var userEmail: String = ""
    @Published var userPhone: String = ""
    @Published var userSSID: String = ""
    @Published var customerID: String = ""

    func fetchSetupToken(
        customerID: String? = nil,
        selectedMerchantIntegration: MerchantIntegration,
        paymentType: PaymentType,
        sca: String = "SCA_WHEN_REQUIRED",
        appSwitchURL: String? = nil
    ) async throws -> CreateSetupTokenResponse {
        do {
            state.setupTokenResponse = .loading

            let experienceContext = VaultExperienceContext(
                appSwitchContext: appSwitchURL.map { AppSwitchContext(appUrl: $0) }
            )

            let paymentSourceType: PaymentSourceType
            switch paymentType {
            case .card:
                paymentSourceType = PaymentSourceType.card(verification: sca, experienceContext: experienceContext)
            case .paypal:
                paymentSourceType = PaymentSourceType.paypal(usageType: "MERCHANT", experienceContext: experienceContext)
            }

            let setupTokenResult = try await DemoMerchantAPI.shared.createSetupToken(
                customerID: customerID,
                selectedMerchantIntegration: selectedMerchantIntegration,
                paymentSourceType: paymentSourceType
            )
            state.setupTokenResponse = .loaded(setupTokenResult)
            return setupTokenResult
        } catch {
            state.setupTokenResponse = .error(message: error.localizedDescription)
            throw error
        }
    }

    func resetState() {
        state = VaultState()
        selectedUserAction = .setupNow
        selectedUserIdentity = .none
        userEmail = ""
        userPhone = ""
        userSSID = ""
        customerID = ""
    }

    func getPaymentToken(
        setupToken: String,
        selectedMerchantIntegration: MerchantIntegration
    ) async throws {
        do {
            DispatchQueue.main.async {
                self.state.paymentTokenResponse = .loading
            }
            let paymentTokenResult = try await DemoMerchantAPI.shared.createPaymentToken(
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
