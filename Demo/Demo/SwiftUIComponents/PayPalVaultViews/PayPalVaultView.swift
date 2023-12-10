import SwiftUI

struct PayPalVaultView: View {

    @StateObject var paypalVaultViewModel = PayPalVaultViewModel()

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateSetupTokenView(
                        selectedMerchantIntegration: DemoSettings.merchantIntegration,
                        vaultViewModel: paypalVaultViewModel,
                        paymentSourceType: PaymentSourceType.paypal(usageType: "MERCHANT")
                    )
                    SetupTokenResultView(vaultViewModel: paypalVaultViewModel)
                    if let url = paypalVaultViewModel.state.setupToken?.paypalURL {
                        Button("Vault PayPal") {
                            Task {
                                await paypalVaultViewModel.vault(url: url)
                            }
                        }
                        .buttonStyle(RoundedBlueButtonStyle())
                        .padding()
                    }
                    PayPalVaultResultView(paypalVaultViewModel: paypalVaultViewModel)
                    if let paypalVaultResult = paypalVaultViewModel.paypalVaultToken {
                        CreatePaymentTokenView(
                            vaultViewModel: paypalVaultViewModel,
                            selectedMerchantIntegration: DemoSettings.merchantIntegration,
                            setupToken: paypalVaultResult.tokenID
                        )
                    }
                    PaymentTokenResultView(vaultViewModel: paypalVaultViewModel)
                    switch paypalVaultViewModel.state.paymentTokenResponse {
                    case .loaded, .error:
                        VStack {
                            Button("Reset") {
                                paypalVaultViewModel.resetState()
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
                        .onChange(of: paypalVaultViewModel.state) { _ in
                            withAnimation {
                                scrollView.scrollTo("bottomView")
                            }
                        }
                        .onChange(of: paypalVaultViewModel.paypalVaultToken) { _ in
                            withAnimation {
                                scrollView.scrollTo("bottomView")
                            }
                        }
                }
            }
        }
    }
}
