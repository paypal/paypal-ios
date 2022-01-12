import SwiftUI
import PayPal

// TODO: Add PayPal button once buttons are updated as SwiftUI accessible views

@available(iOS 13.0.0, *)
struct SwiftUIPayPalDemo: View {

    @StateObject var baseViewModel = BaseViewModel()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 50) {
                PayPalButton.Representable {
                    baseViewModel.payPalButtonTapped()
                }
                .cornerRadius(4)
                .frame(maxWidth: .infinity, maxHeight: 40)
                PayPalCreditButton.Representable {
                    baseViewModel.payPalButtonTapped()
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
