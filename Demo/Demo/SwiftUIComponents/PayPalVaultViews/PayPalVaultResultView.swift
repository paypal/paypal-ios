import SwiftUI

struct PayPalVaultResultView: View {

    @ObservedObject var vaultViewModel: VaultViewModel

    var body: some View {
        switch vaultViewModel.state.paypalVaultTokenResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let vaultToken):
            getSuccessView(vaultToken: vaultToken)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSuccessView(vaultToken: String) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Token")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(vaultToken)")
            LeadingText("Status", weight: .bold)
            LeadingText("APPROVED")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
