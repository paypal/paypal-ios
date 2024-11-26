import SwiftUI

class VaultViewModel: ObservableObject {

    @Published var state = VaultState()

    func getSetupToken(
        customerID: String? = nil,
        selectedMerchantIntegration: MerchantIntegration,
        paymentSourceType: PaymentSourceType
    ) async throws {
        do {
            DispatchQueue.main.async {
                self.state.setupTokenResponse = .loading
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
