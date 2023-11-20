import SwiftUI

struct PayPalWebOrderCompletionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    if let orderID = payPalWebViewModel.order?.id {
                        PayPalWebCompleteTransactionView(
                            intent: payPalWebViewModel.intent,
                            orderID: orderID,
                            payPalWebViewModel: payPalWebViewModel
                        )
                        Text("")
                            .id("bottomView")
                        Spacer()
                            .onChange(of: payPalWebViewModel.state) { _ in
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
