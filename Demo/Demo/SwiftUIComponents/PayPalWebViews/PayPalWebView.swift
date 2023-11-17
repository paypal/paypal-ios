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
                if let order = payPalWebViewModel.state.order {
                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .started)
                    NavigationLink {
                        PayPalTransactionView(paypalWebViewModel: payPalWebViewModel, orderID: order.id)
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
