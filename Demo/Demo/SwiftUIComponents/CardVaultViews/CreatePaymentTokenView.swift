import SwiftUI

struct CreatePaymentTokenView: View {

    let setupToken: String
    @ObservedObject var cardVaultViewModel: CardVaultViewModel
    @ObservedObject var baseViewModel: BaseViewModel
    @State private var isLoading = false

    public init(baseViewModel: BaseViewModel, cardVaultViewModel: CardVaultViewModel, setupToken: String) {
        self.cardVaultViewModel = cardVaultViewModel
        self.baseViewModel = baseViewModel
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
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                Button("Create Payment Token") {
                    Task {
                        do {
                            isLoading = true
                            try await cardVaultViewModel.getPaymentToken(
                                setupToken: setupToken,
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
