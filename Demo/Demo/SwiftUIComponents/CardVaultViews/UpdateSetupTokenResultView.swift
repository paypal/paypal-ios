import SwiftUI

struct UpdateSetupTokenResultView: View {

    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    var body: some View {
        switch cardVaultViewModel.state.updateSetupTokenResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let updateSetupTokenResponse):
            getSuccessView(updateSetupTokenResponse: updateSetupTokenResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSuccessView(updateSetupTokenResponse: UpdateSetupTokenResult) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Success")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(updateSetupTokenResponse.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(updateSetupTokenResponse.status)")
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
