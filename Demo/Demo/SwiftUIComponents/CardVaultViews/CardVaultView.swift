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
                        Button("\(intent)") {
                            if intent == "CAPTURE" {
                                Task {
                                    do {
                                        try await cardVaultViewModel.captureOrder(
                                            orderID: order.id,
                                            selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration
                                        )
                                        print("Order Captured. ID: \(cardVaultViewModel.state.capturedOrder?.id ?? "")")
                                    } catch {
                                        print("Error capturing order: \(error.localizedDescription)")
                                    }
                                }
                            } else {
                                Task {
                                    do {
                                        try await cardVaultViewModel.authorizeOrder(
                                            orderID: order.id,
                                            selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration
                                        )
                                        print("Order Authorized. ID: \(cardVaultViewModel.state.authorizedOrder?.id ?? "")")
                                    } catch {
                                        print("Error authorizing order: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                        .buttonStyle(RoundedBlueButtonStyle())
                    }
                    switch cardVaultViewModel.state.createdOrderResponse {
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
