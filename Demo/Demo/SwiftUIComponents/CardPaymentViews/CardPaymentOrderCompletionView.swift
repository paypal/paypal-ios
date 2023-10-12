import SwiftUI

struct CardPaymentOrderCompletionView: View {

    let orderID: String
    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    CardApprovalResultView(cardPaymentViewModel: cardPaymentViewModel)
                    if cardPaymentViewModel.state.approveResult != nil {
                        CardOrderActionButton(
                            intent: cardPaymentViewModel.state.intent,
                            orderID: orderID,
                            selectedMerchantIntegration: DemoSettings.merchantIntegration,
                            cardPaymentViewModel: cardPaymentViewModel
                        )
                    }

                    if cardPaymentViewModel.state.authorizedOrder != nil || cardPaymentViewModel.state.capturedOrder != nil {
                        CardOrderCompletionResultView(cardPaymentViewModel: cardPaymentViewModel)
                    }
                    Text("")
                        .id("bottomView")
                    Spacer()
                }
                .onChange(of: cardPaymentViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}
