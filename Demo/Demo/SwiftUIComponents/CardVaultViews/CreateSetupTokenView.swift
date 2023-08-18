import SwiftUI

struct CreateSetupTokenView: View {

    @State private var vaultCustomerID: String = ""
    @ObservedObject var cardVaultViewModel: CardVaultViewModel
    @ObservedObject var baseViewModel: BaseViewModel
    @State private var isLoading = false

    public init(baseViewModel: BaseViewModel, cardVaultViewModel: CardVaultViewModel) {
        self.cardVaultViewModel = cardVaultViewModel
        self.baseViewModel = baseViewModel
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
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Button("Create Setup Token") {
                    Task {
                        do {
                            isLoading = true
                            try await cardVaultViewModel.getSetupToken(
                                customerID: vaultCustomerID,
                                selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration
                            )
                            isLoading = false
                        } catch {
                            isLoading = false
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
