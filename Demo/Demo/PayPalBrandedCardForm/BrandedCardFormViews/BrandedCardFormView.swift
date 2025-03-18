import SwiftUI

struct BrandedCardFormView: View {

    @StateObject var cardFormViewModel = BrandedCardFormViewModel()

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {

                    BrandedCardCreateOrderView(cardFormViewModel: cardFormViewModel)

                    if case .loaded = cardFormViewModel.state.createdOrderResponse {
                        BrandedCardOrderCreateResultView(cardFormViewModel: cardFormViewModel)

//                        PayPalWebButtonsView(payPalWebViewModel: payPalWebViewModel)
                    }

                    if case .loaded = cardFormViewModel.state.approveResultResponse {
//                        PayPalApprovalResultView(payPalWebViewModel: payPalWebViewModel)
//
//                        PayPalWebTransactionView(payPalWebViewModel: payPalWebViewModel)
//                            .padding(.bottom, 20)
                    }

                    if case .loaded = cardFormViewModel.state.capturedOrderResponse {
//                        PayPalOrderCompletionResultView(payPalWebViewModel: payPalWebViewModel)
                    } else if case .loaded = cardFormViewModel.state.authorizedOrderResponse {
//                        PayPalOrderCompletionResultView(payPalWebViewModel: payPalWebViewModel)
                    }
                    Text("")
                        .id("bottomView")
                }
                .onChange(of: cardFormViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}

