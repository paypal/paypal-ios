import SwiftUI
import PayPalWebPayments

struct PayPalVaultResultView: View {

    @ObservedObject var viewModel: PayPalVaultViewModel

    var body: some View {
        switch viewModel.state.paypalVaultTokenResponse {
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
                Text("Vault Success")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(result.tokenID)")
            LeadingText("Status", weight: .bold)
            LeadingText("APPROVED")
            LeadingText("Approval Session ID", weight: .bold)
            LeadingText("\(result.approvalSessionID)")
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
