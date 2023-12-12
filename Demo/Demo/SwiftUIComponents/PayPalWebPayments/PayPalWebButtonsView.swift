import SwiftUI
import PaymentButtons
import PayPalWebPayments

struct PayPalWebButtonsView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    @State private var selectedFundingSource: PayPalWebCheckoutFundingSource = .paypal

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 40) {
                Picker("Funding Source", selection: $selectedFundingSource) {
                    Text("PayPal").tag(PayPalWebCheckoutFundingSource.paypal)
                    Text("PayPal Credit").tag(PayPalWebCheckoutFundingSource.paylater)
                    Text("Pay Later").tag(PayPalWebCheckoutFundingSource.paypalCredit)
                }
                .pickerStyle(SegmentedPickerStyle())

                switch selectedFundingSource {
                case .paypalCredit:
                    PayPalCreditButton.Representable(color: .black, size: .full) {
                        payPalWebViewModel.paymentButtonTapped(funding: .paypalCredit)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                case .paylater:
                    PayPalPayLaterButton.Representable(color: .silver, edges: .softEdges, size: .full) {
                        payPalWebViewModel.paymentButtonTapped(funding: .paylater)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                case .paypal:
                    PayPalButton.Representable(color: .blue, size: .full) {
                        payPalWebViewModel.paymentButtonTapped(funding: .paypal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 40)
                }
            }
            .padding(20)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
                    .padding(5)
            )

            if payPalWebViewModel.checkoutResult != nil && payPalWebViewModel.state == .success {
                PayPalWebResultView(payPalWebViewModel: payPalWebViewModel)
                NavigationLink {
                    PayPalWebTransactionView(payPalWebViewModel: payPalWebViewModel)
                        .navigationTitle("Complete Transaction")
                } label: {
                    Text("Complete Transaction")
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()
            } else if case .error = payPalWebViewModel.state {
                PayPalWebResultView(payPalWebViewModel: payPalWebViewModel)
            }
            Spacer()
        }
    }
}
