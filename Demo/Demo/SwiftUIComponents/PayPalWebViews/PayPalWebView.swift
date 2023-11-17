import SwiftUI
import PaymentButtons

struct PayPalWebView: View {

    @StateObject var payPalWebViewModel = PayPalWebViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CreateOrderPayPalWebView(
                    paypalWebViewModel: payPalWebViewModel,
                    selectedMerchantIntegration: DemoSettings.merchantIntegration
                )
                PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .started)
                NavigationLink {
                    // TODO: figure this out
//                    PayPalTransactionView(paypalWebViewModel: payPalWebViewModel, orderID: payPalWebViewModel.id)
//                        .navigationTitle("PayPal Transactions")
                } label: {
                    Text("PayPal Transactions")
                }
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()
            }
        }
    }
}
