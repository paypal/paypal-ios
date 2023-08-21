import SwiftUI

struct CreatePaymentTokenView: View {

    let selectedMerchantIntegration: MerchantIntegration
    let setupToken: String

    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    public init(cardVaultViewModel: CardVaultViewModel, selectedMerchantIntegration: MerchantIntegration, setupToken: String) {
        self.cardVaultViewModel = cardVaultViewModel
        self.selectedMerchantIntegration = selectedMerchantIntegration
        self.setupToken = setupToken
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create a Permanent Payment Method Token")
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            ZStack {
                if case .loading = cardVaultViewModel.state.paymentTokenResponse {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                Button("Create Payment Token") {
                    Task {
                        do {
                            try await cardVaultViewModel.getPaymentToken(
                                setupToken: setupToken,
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
