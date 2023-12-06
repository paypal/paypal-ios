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
                        ZStack {
                            Button("Vault Card") {
                                Task {
                                    await paypalVaultViewModel.vault(url: url)
                                }
                            }
                            .buttonStyle(RoundedBlueButtonStyle())
                            // handling loading view
                        }
                        .padding()
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
                }
            }
        }
    }
}
