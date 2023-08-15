import SwiftUI

struct CardVaultView: View {

    @StateObject var baseViewModel = BaseViewModel()
    @StateObject var cardVaultViewModel = CardVaultViewModel()

    private let cardFormatter = CardFormatter()

    // MARK: Views

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateSetupTokenView(baseViewModel: baseViewModel, cardVaultViewModel: cardVaultViewModel)
                    if let setupTokenResponse = cardVaultViewModel.state.setupTokenResponse {
                        SetupTokenResultView(setupTokenResponse: setupTokenResponse)
                        let setupToken = setupTokenResponse.id
                        UpdateSetupTokenView(baseViewModel: baseViewModel, cardVaultViewModel: cardVaultViewModel, setupToken: setupToken)
                            .id("updateSetupTokenView")
                    }
                    if let updateSetupTokenResponse = cardVaultViewModel.state.updateSetupToken {
                        let setupToken = updateSetupTokenResponse.id
                        UpdateSetupTokenResultView(updateSetupTokenResponse: updateSetupTokenResponse)
                        CreatePaymentTokenView(baseViewModel: baseViewModel, cardVaultViewModel: cardVaultViewModel, setupToken: setupToken)
                            .id("createPaymentTokenView")
                    }
                    if let paymentTokenResponse = cardVaultViewModel.state.paymentTokenResponse {
                        PaymentTokenResultView(paymentTokenResponse: paymentTokenResponse)
                            .id("paymentTokenResultView")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.horizontal, 10)
                .padding(.top, 10)
                .onChange(of: cardVaultViewModel.state.setupTokenResponse?.id) { _ in
                    withAnimation {
                        scrollView.scrollTo("updateSetupTokenView")
                    }
                }
                .onChange(of: cardVaultViewModel.state.updateSetupToken?.id) { _ in
                    withAnimation {
                        scrollView.scrollTo("createPaymentTokenView")
                    }
                }
                .onChange(of: cardVaultViewModel.state.paymentTokenResponse?.id) { _ in
                    withAnimation {
                        scrollView.scrollTo("paymentTokenResultView")
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
