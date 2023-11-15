import SwiftUI
import PaymentButtons

struct PayPalWebView: View {

    @StateObject var paypalWebViewModel = PayPalWebViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CreateOrderPayPalWebView(
                    paypalWebViewModel: paypalWebViewModel,
                    selectedMerchantIntegration: DemoSettings.merchantIntegration
                )
                if let order = paypalWebViewModel.state.createOrder {
                    OrderCreatePayPalWebResultView(paypalWebViewModel: paypalWebViewModel)
                    NavigationLink {
                        PayPalTransactionView(paypalWebViewModel: paypalWebViewModel, orderID: order.id)
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
