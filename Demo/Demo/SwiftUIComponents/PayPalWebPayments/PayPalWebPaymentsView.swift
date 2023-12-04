import SwiftUI

struct PayPalWebPaymentsView: View {

    @StateObject var payPalWebViewModel = PayPalWebViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PayPalWebCreateOrderView(payPalWebViewModel: payPalWebViewModel)
                if payPalWebViewModel.createOrderResult != nil && payPalWebViewModel.state == .success {
                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .created)
                    NavigationLink {
                        PayPalWebButtonsView(payPalWebViewModel: payPalWebViewModel)
                            .navigationTitle("Checkout with PayPal")
                    } label: {
                        Text("Checkout with PayPal")
                    }
                    .buttonStyle(RoundedBlueButtonStyle())
                    .padding()
                } else if case .error = payPalWebViewModel.state {
                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .error)
                }
            }
        }
    }
}
