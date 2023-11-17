import SwiftUI

struct PayPalWebOrderCompletionView: View {

    let orderID: String
    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        let state = payPalWebViewModel.state
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .started)
                    if state.orderResponse != nil {
                        PayPalOrderActionButton(
                            intent: state.intent,
                            orderID: orderID,
                            selectedMerchantIntegration: DemoSettings.merchantIntegration,
                            paypalWebViewModel: payPalWebViewModel
                        )
                    }

                    if state.order != nil {
                        PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .started)
                    }
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
