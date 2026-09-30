import SwiftUI

struct CardVaultView: View {
    
    @Environment(CardVaultViewModel.self)
    var viewModel
    
    var isCreateSetupTokenLoading: Bool {
        viewModel.createSetupTokenState.isLoading
    }

    // MARK: Views
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateCardSetupTokenView(isLoading: isCreateSetupTokenLoading) { request in
                        viewModel.createSetupToken(with: request)
                    }
                    if let setupTokenResponse = viewModel.createSetupTokenState.value {
                        CreateSetupTokenResponseView(response: setupTokenResponse)
                    }
                }
            }
        }
    }
}

// TODO: move to its own file
struct CreateSetupTokenResponseView: View {
    
    let response: CreateSetupTokenResponse
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Setup Token")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(response.id)")
            LeadingText("Customer ID", weight: .bold)
            LeadingText("\(response.customer?.id ?? "")")
            LeadingText("Status", weight: .bold)
            LeadingText("\(response.status)")
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

struct CardVault_Previews: PreviewProvider {

    static var previews: some View {
        CardVaultView()
    }
}
