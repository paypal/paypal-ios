import SwiftUI

struct CardVaultView: View {
    
    @Environment(CardVaultViewModel.self)
    var viewModel

    // MARK: Views
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateCardSetupTokenView(isLoading: false) { request in
                        viewModel.createSetupToken(with: request)
                    }
                }
            }
        }
    }
}

struct CardVault_Previews: PreviewProvider {

    static var previews: some View {
        CardVaultView()
    }
}
