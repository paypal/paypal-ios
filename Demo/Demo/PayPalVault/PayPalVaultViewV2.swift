import SwiftUI

struct PayPalVaultViewV2: View {
    
    @Environment(PayPalVaultViewModelV2.self)
    var viewModel
    
    var isCreateSetupTokenLoading: Bool {
        viewModel.createSetupTokenState.isLoading
    }

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateCardSetupTokenForm(isLoading: isCreateSetupTokenLoading) { request in
                        viewModel.createSetupToken(with: request)
                    }
                    if let createSetupTokenResponse = viewModel.createSetupTokenState.value {
                        CreateSetupTokenResponseView(response: createSetupTokenResponse)
                    }
                }
            }
        }
    }
}
