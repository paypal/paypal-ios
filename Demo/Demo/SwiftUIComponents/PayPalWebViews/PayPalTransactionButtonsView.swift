import SwiftUI
import PaymentButtons

struct PayPalTransactionButtonsView: View {

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel
    let orderID: String

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 40) {
                PayPalButton.Representable(color: .blue, size: .mini) {
                    paypalWebViewModel.paymentButtonTapped(orderID: orderID, funding: .paypal)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalCreditButton.Representable(color: .black, edges: .softEdges, size: .expanded) {
                    paypalWebViewModel.paymentButtonTapped(orderID: orderID, funding: .paypalCredit)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalPayLaterButton.Representable(color: .silver, edges: .rounded, size: .full) {
                    paypalWebViewModel.paymentButtonTapped(orderID: orderID, funding: .paylater)
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
            PayPalWebApprovalView(paypalWebViewModel: paypalWebViewModel)
            if paypalWebViewModel.state.checkoutResult != nil {
                NavigationLink {
                    PayPalWebOrderCompletionView(orderID: orderID, payPalWebViewModel: paypalWebViewModel)
                } label: {
                    Text("Complete Order Transaction")
                }
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()
            }
            Spacer()
        }
    }
}
