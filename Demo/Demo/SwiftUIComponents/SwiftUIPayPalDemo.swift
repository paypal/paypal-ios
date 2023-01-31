import SwiftUI
import PaymentButtons

struct SwiftUIPayPalDemo: View {

    @StateObject var baseViewModel = BaseViewModel()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 40) {
                PayPalButton.Representable(color: .blue, size: .mini) {
                    baseViewModel.paymentButtonTapped(funding: .paypal)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalCreditButton.Representable(color: .black, edges: .softEdges, size: .expanded) {
                    baseViewModel.paymentButtonTapped(funding: .paypalCredit)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalPayLaterButton.Representable(color: .silver, edges: .rounded, size: .full) {
                    baseViewModel.paymentButtonTapped(funding: .paylater)
                }
                .frame(maxWidth: .infinity, maxHeight: 40)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct SwiftUIPayPalView_Previews: PreviewProvider {

    static var previews: some View {
        SwiftUIPayPalDemo()
    }
}
