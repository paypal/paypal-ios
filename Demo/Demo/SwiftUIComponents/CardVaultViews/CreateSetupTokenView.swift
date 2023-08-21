import SwiftUI

struct CreateSetupTokenView: View {

    let selectedMerchantIntegration: MerchantIntegration

    @State private var vaultCustomerID: String = ""
    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    public init(selectedMerchantIntegration: MerchantIntegration, cardVaultViewModel: CardVaultViewModel) {
        self.selectedMerchantIntegration = selectedMerchantIntegration
        self.cardVaultViewModel = cardVaultViewModel
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
                if case .loading = cardVaultViewModel.state.setupTokenResponse {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                Button("Create Setup Token") {
                    Task {
                        do {
                            try await cardVaultViewModel.getSetupToken(
                                customerID: vaultCustomerID,
                                selectedMerchantIntegration: selectedMerchantIntegration
                            )
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue)
            .cornerRadius(10)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
        .padding(5)
    }
}
