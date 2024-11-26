import SwiftUI

struct SetupTokenResultView: View {

    @ObservedObject var vaultViewModel: VaultViewModel

    var body: some View {
        switch vaultViewModel.state.setupTokenResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let setupTokenResponse):
            getSuccessView(setupTokenResponse: setupTokenResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSuccessView(setupTokenResponse: CreateSetupTokenResponse) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Setup Token")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(setupTokenResponse.id)")
            LeadingText("Customer ID", weight: .bold)
            LeadingText("\(setupTokenResponse.customer?.id ?? "")")
            LeadingText("Status", weight: .bold)
            LeadingText("\(setupTokenResponse.status)")
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
