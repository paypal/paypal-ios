import SwiftUI

struct PayPalWebOrderCompletionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        let state = payPalWebViewModel.state
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    if let orderID = payPalWebViewModel.order?.id {
                        PayPalOrderActionButton(
                            intent: payPalWebViewModel.intent,
                            orderID: orderID,
                            selectedMerchantIntegration: DemoSettings.merchantIntegration,
                            payPalWebViewModel: payPalWebViewModel
                        )
                        Text("")
                            .id("bottomView")
                        Spacer()
                        .onChange(of: state) { _ in
                            withAnimation {
                                scrollView.scrollTo("bottomView")
                            }
                        }
                    }
                }
            }
        }
    }
}
