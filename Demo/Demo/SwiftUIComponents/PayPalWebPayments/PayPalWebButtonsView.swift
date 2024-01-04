import SwiftUI
import PaymentButtons
import PayPalWebPayments

struct PayPalWebButtonsView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    @State private var selectedFundingSource: PayPalWebCheckoutFundingSource = .paypal

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 40) {
                PayPalButton.Representable(color: .gold, size: .mini) {
                    payPalWebViewModel.paymentButtonTapped(funding: .paypal)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalCreditButton.Representable(color: .gold, edges: .softEdges, size: .expanded) {
                    payPalWebViewModel.paymentButtonTapped(funding: .paypalCredit)
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
                            Text("PayPal Credit").tag(PayPalWebCheckoutFundingSource.paylater)
                            Text("Pay Later").tag(PayPalWebCheckoutFundingSource.paypalCredit)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch selectedFundingSource {
                        case .paypalCredit:
                            PayPalCreditButton.Representable(color: .gold, size: .full) {
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
    }
}
