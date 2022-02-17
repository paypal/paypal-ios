import SwiftUI
import PayPal

@available(iOS 13.0.0, *)
struct SwiftUIPayPalDemo: View {

    @StateObject var baseViewModel = BaseViewModel()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 50) {
                PayPalButton {
                    baseViewModel.payPalButtonTapped(context: FeatureBaseViewController(baseViewModel: BaseViewModel()))
                }
                .cornerRadius(4)
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalCreditButton {
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
