import SwiftUI
import PayPalWebPayments

struct PayPalVaultResultView: View {

    @ObservedObject var paypalVaultViewModel: PayPalVaultViewModel

    var body: some View {
        switch paypalVaultViewModel.paypalVaultTokenResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let vaultResult):
            getSuccessView(result: vaultResult)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSuccessView(result: PayPalVaultResult) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Token")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Vault Token ID", weight: .bold)
            LeadingText("\(result.tokenID)")
            LeadingText("Approval Session ID", weight: .bold)
            LeadingText("\(result.approvalSessionID)")
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
