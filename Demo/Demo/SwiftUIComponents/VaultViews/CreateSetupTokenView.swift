import SwiftUI

struct CreateSetupTokenView: View {

    let selectedMerchantIntegration: MerchantIntegration

    @State private var vaultCustomerID: String = ""
    @ObservedObject var vaultViewModel: VaultViewModel

    let paymentSourceType: PaymentSourceType

    public init(selectedMerchantIntegration: MerchantIntegration, vaultViewModel: VaultViewModel, paymentSourceType: PaymentSourceType) {
        self.selectedMerchantIntegration = selectedMerchantIntegration
        self.vaultViewModel = vaultViewModel
        self.paymentSourceType = paymentSourceType
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault without Purchase requires creation of setup token:")
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $vaultCustomerID)
            ZStack {
                Button("Create Setup Token") {
                    Task {
                        do {
                            try await vaultViewModel.getSetupToken(
                                customerID: vaultCustomerID.isEmpty ? nil : vaultCustomerID,
                                selectedMerchantIntegration: selectedMerchantIntegration,
                                paymentSourceType: paymentSourceType
                            )
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = vaultViewModel.state.setupTokenResponse {
                    CircularProgressView()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
