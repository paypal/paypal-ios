import SwiftUI

struct CardVaultView: View {

    @StateObject var baseViewModel = BaseViewModel()
    @StateObject var cardVaultViewModel = CardVaultViewModel()

    @State var intent: String = "AUTHORIZE"

    // MARK: Views

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateSetupTokenView(
                        selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration,
                        cardVaultViewModel: cardVaultViewModel
                    )
                    SetupTokenResultView(cardVaultViewModel: cardVaultViewModel)
                    if let setupToken = cardVaultViewModel.state.setupToken {
                        UpdateSetupTokenView(baseViewModel: baseViewModel, cardVaultViewModel: cardVaultViewModel, setupToken: setupToken.id)
                    }
                    UpdateSetupTokenResultView(cardVaultViewModel: cardVaultViewModel)
                    if let updateSetupToken = cardVaultViewModel.state.updateSetupToken {
                        CreatePaymentTokenView(
                            cardVaultViewModel: cardVaultViewModel,
                            selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration,
                            setupToken: updateSetupToken.id
                        )
                    }
                    PaymentTokenResultView(cardVaultViewModel: cardVaultViewModel)
                    if cardVaultViewModel.state.paymentToken != nil {
                        CreateOrderVaultView(
                            cardVaultViewModel: cardVaultViewModel,
                            selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration,
                            intent: $intent
                            )
                    }
                    if let order = cardVaultViewModel.state.createdOrder {
                        OrderCreateResultView(cardVaultViewModel: cardVaultViewModel)
                        OrderActionButton(
                            intent: intent,
                            order: order,
                            selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration,
                            cardVaultViewModel: cardVaultViewModel
                            )
                    }
                    // should check for both capture or authorize responses
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
}

struct CardVault_Previews: PreviewProvider {

    static var previews: some View {
        CardVaultView()
    }
}
