import SwiftUI
import PaymentButtons
import PayPalWebPayments

struct PayPalWebButtonsView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    @State private var selectedFundingSource: PayPalWebCheckoutFundingSource = .paypal

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 16) {
                HStack {
                    Text("Checkout with PayPal")
                        .font(.system(size: 20))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .font(.headline)
                Picker("Funding Source", selection: $selectedFundingSource) {
                    Text("PayPal").tag(PayPalWebCheckoutFundingSource.paypal)
                    Text("PayPal Credit").tag(PayPalWebCheckoutFundingSource.paypalCredit)
                    Text("Pay Later").tag(PayPalWebCheckoutFundingSource.paylater)
                }
                .pickerStyle(SegmentedPickerStyle())
                ZStack {
                    switch selectedFundingSource {
                    case .paypalCredit:
                        PayPalCreditButton.Representable(color: .black, size: .full) {
                            payPalWebViewModel.paymentButtonTapped(funding: .paypalCredit)
                        }
                    case .paylater:
                        PayPalPayLaterButton.Representable(color: .silver, edges: .softEdges, size: .full) {
                            payPalWebViewModel.paymentButtonTapped(funding: .paylater)
                        }
                    case .paypal:
                        PayPalButton.Representable(color: .blue, size: .full) {
                            payPalWebViewModel.paymentButtonTapped(funding: .paypal)
                        }
                    }
                    if payPalWebViewModel.state.approveResultResponse == .loading &&
                        payPalWebViewModel.checkoutResult == nil &&
                        payPalWebViewModel.orderID != nil {
                        CircularProgressView()
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
                    .padding(5)
            )
        }
    }
}
