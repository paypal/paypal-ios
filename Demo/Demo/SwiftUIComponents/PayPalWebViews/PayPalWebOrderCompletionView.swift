import SwiftUI

struct PayPalWebOrderCompletionView: View {

    let orderID: String
    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        let state = payPalWebViewModel.state
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    // TODO: figure out sending intent - maybe in VM?
                    PayPalOrderActionButton(
                        intent: .authorize,
                        orderID: orderID,
                        selectedMerchantIntegration: DemoSettings.merchantIntegration,
                        paypalWebViewModel: payPalWebViewModel
                    )

                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .started)
                    Text("")
                        .id("bottomView")
                    Spacer()
                }
                .onChange(of: state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}
