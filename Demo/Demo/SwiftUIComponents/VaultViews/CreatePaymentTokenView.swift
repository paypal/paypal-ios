import SwiftUI

struct CreatePaymentTokenView: View {

    let selectedMerchantIntegration: MerchantIntegration
    let setupToken: String

    @ObservedObject var vaultViewModel: VaultViewModel

    public init(vaultViewModel: VaultViewModel, selectedMerchantIntegration: MerchantIntegration, setupToken: String) {
        self.vaultViewModel = vaultViewModel
        self.selectedMerchantIntegration = selectedMerchantIntegration
        self.setupToken = setupToken
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create a Payment Method Token")
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            ZStack {
                Button("Create Payment Token") {
                    Task {
                        do {
                            try await vaultViewModel.getPaymentToken(
                                setupToken: setupToken,
                                selectedMerchantIntegration: selectedMerchantIntegration
                            )
                        } catch {
                            print("Error in getting payment token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = vaultViewModel.state.paymentTokenResponse {
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
