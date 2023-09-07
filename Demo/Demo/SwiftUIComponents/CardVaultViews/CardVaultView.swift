import SwiftUI

struct CardVaultView: View {

    @StateObject var baseViewModel = BaseViewModel()
    @StateObject var cardVaultViewModel = CardVaultViewModel()

    // MARK: Views

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    setupTokenSectionView
                    updateSetupTokenSectionView
                    paymentTokenSectionView
                    orderCreateSectionView
                    orderCompletionSectionView
                    switch cardVaultViewModel.state.authorizedOrderResponse {
                    case .loaded, .error:
                        VStack {
                            Button("Reset") {
                                cardVaultViewModel.resetState()
                            }
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.gray)
                            .cornerRadius(10)
                        }
                        .padding(5)
                    default:
                        EmptyView()
                    }
                    switch cardVaultViewModel.state.capturedOrderResponse {
                    case .loaded, .error:
                        VStack {
                            Button("Reset") {
                                cardVaultViewModel.resetState()
                            }
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.gray)
                            .cornerRadius(10)
                        }
                        .padding(5)
                    default:
                        EmptyView()
                    }
                    Text("")
                        .id("bottomView")
                        .frame(maxWidth: .infinity, alignment: .top)
                        .padding(.horizontal, 10)
                        .onChange(of: cardVaultViewModel.state) { _ in
                            withAnimation {
                                scrollView.scrollTo("bottomView")
                            }
                        }
                }
            }
        }
    }

    @ViewBuilder var setupTokenSectionView: some View {
        CreateSetupTokenView(
            selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration,
            cardVaultViewModel: cardVaultViewModel
        )
        SetupTokenResultView(cardVaultViewModel: cardVaultViewModel)
    }

    @ViewBuilder var updateSetupTokenSectionView: some View {
        if let setupToken = cardVaultViewModel.state.setupToken {
            UpdateSetupTokenView(baseViewModel: baseViewModel, cardVaultViewModel: cardVaultViewModel, setupToken: setupToken.id)
        }
        UpdateSetupTokenResultView(cardVaultViewModel: cardVaultViewModel)
    }

    @ViewBuilder var paymentTokenSectionView: some View {
        if let updateSetupToken = cardVaultViewModel.state.updateSetupToken {
            CreatePaymentTokenView(
                cardVaultViewModel: cardVaultViewModel,
                selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration,
                setupToken: updateSetupToken.id
            )
        }
        PaymentTokenResultView(cardVaultViewModel: cardVaultViewModel)
    }

    @ViewBuilder var orderCreateSectionView: some View {
        if cardVaultViewModel.state.paymentToken != nil {
            CreateOrderVaultView(
                cardVaultViewModel: cardVaultViewModel,
                selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration
            )
        }
        OrderCreateResultView(cardVaultViewModel: cardVaultViewModel)
    }

    @ViewBuilder var orderCompletionSectionView: some View {
        if let order = cardVaultViewModel.state.createdOrder {
            OrderActionButton(
                order: order,
                selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration,
                cardVaultViewModel: cardVaultViewModel
            )
        }
        OrderCompletionResultView(cardVaultViewModel: cardVaultViewModel)
    }
}

struct CardVault_Previews: PreviewProvider {

    static var previews: some View {
        CardVaultView()
    }
}
