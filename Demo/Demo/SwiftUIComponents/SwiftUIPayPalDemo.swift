import SwiftUI
import PayPalUI

struct SwiftUIPayPalDemo: View {

    @StateObject var baseViewModel = BaseViewModel()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 40) {
                PayPalButtonSwiftUI(color: .blue, size: .mini) {
                    baseViewModel.payPalButtonTapped(context: FeatureBaseViewController(baseViewModel: BaseViewModel()))
                }
//                .frame(maxWidth: .infinity, maxHeight: 40)
//                PayPalCreditButton(color: .black, edges: .softEdges, size: .expanded) {
//                    baseViewModel.payPalCreditButtonTapped(context: FeatureBaseViewController(baseViewModel: BaseViewModel()))
//                }
//                .frame(maxWidth: .infinity, maxHeight: 40)
//                PayPalPayLaterButton(color: .silver, edges: .rounded, size: .full) {
//                    baseViewModel.payPalCreditButtonTapped(context: FeatureBaseViewController(baseViewModel: BaseViewModel()))
//                }
//                .frame(maxWidth: .infinity, maxHeight: 40)
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
