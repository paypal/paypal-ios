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
                if let order = payPalWebViewModel.order {
                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .started)
                    NavigationLink {
                        PayPalTransactionView(payPalWebViewModel: payPalWebViewModel)
                            .navigationTitle("PayPal Transactions")
                    } label: {
                        Text("PayPal Transactions")
                    }
                    .buttonStyle(RoundedBlueButtonStyle())
                    .padding()
                }
            }
        }
    }
}
