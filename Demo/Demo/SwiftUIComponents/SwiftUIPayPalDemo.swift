import SwiftUI

@available(iOS 13.0.0, *)
struct SwiftUIPayPalDemo: View {

    @StateObject var baseViewModel = BaseViewModel()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 50) {
                Button("Pay with PayPal") {
                    baseViewModel.payPalButtonTapped(context: FeatureBaseViewController(baseViewModel: BaseViewModel()))
                }
                .cornerRadius(4)
                .frame(maxWidth: .infinity, maxHeight: 40)
                Button("Pay with PayPal Credit") {
                    baseViewModel.payPalButtonTapped(context: FeatureBaseViewController(baseViewModel: BaseViewModel()))
                }
                .cornerRadius(4)
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
