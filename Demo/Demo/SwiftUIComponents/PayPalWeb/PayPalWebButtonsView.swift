import SwiftUI
import PaymentButtons

struct PayPalWebButtonsView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 40) {
                PayPalButton.Representable(color: .blue, size: .mini) {
                    payPalWebViewModel.paymentButtonTapped(funding: .paypal)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalCreditButton.Representable(color: .black, edges: .softEdges, size: .expanded) {
                    payPalWebViewModel.paymentButtonTapped(funding: .paypalCredit)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalPayLaterButton.Representable(color: .silver, edges: .rounded, size: .full) {
                    payPalWebViewModel.paymentButtonTapped(funding: .paylater)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
            }
            .padding(20)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
                    .padding(5)
            )

            if payPalWebViewModel.state == .success && payPalWebViewModel.checkoutResult != nil {
                PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .approved)
                NavigationLink {
                    PayPalWebTransactionView(payPalWebViewModel: payPalWebViewModel)
                        .navigationTitle("Complete Transaction")
                } label: {
                    Text("Complete Transaction")
                }
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()
            }
            Spacer()
        }
        .onAppear {
            payPalWebViewModel.resetState()
        }
    }
}
