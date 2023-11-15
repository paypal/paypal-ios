import SwiftUI

struct PayPalWebOrderCompletionView: View {

    let orderID: String
    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        let state = payPalWebViewModel.state
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    PayPalWebApprovalResultView(paypalWebViewModel: payPalWebViewModel)
                    if state.checkoutResult != nil {
                        PayPalOrderActionButton(
                            intent: state.intent,
                            orderID: orderID,
                            selectedMerchantIntegration: DemoSettings.merchantIntegration,
                            paypalWebViewModel: payPalWebViewModel
                        )
                    }

                    if state.authorizedOrder != nil || state.capturedOrder != nil {
                        PayPalWebOrderCompletionResultView(paypalWebViewModel: payPalWebViewModel)
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
