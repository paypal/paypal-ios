import SwiftUI

struct CardPaymentOrderCompletionView: View {

    let orderID: String
    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        let state = cardPaymentViewModel.state
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    CardApprovalResultView(cardPaymentViewModel: cardPaymentViewModel)
                    if state.approveResult != nil {
                        CardOrderActionButton(
                            intent: state.intent,
                            orderID: orderID,
                            selectedMerchantIntegration: DemoSettings.merchantIntegration,
                            cardPaymentViewModel: cardPaymentViewModel
                        )
                    }

                    if state.authorizedOrder != nil || state.capturedOrder != nil {
                        CardOrderCompletionResultView(cardPaymentViewModel: cardPaymentViewModel)
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
