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

                        CardButtonView(cardFormViewModel: cardFormViewModel)
                    }

                    if case .loaded = cardFormViewModel.state.approveResultResponse {
                        BrandedCardApprovalResultView(cardFormViewModel: cardFormViewModel)
                        CardFormOrderCompletionView(cardFormViewModel: cardFormViewModel)
                            .padding(.bottom, 20)
                    }

                    if case .loaded = cardFormViewModel.state.capturedOrderResponse {
                        BrandedCardOrderCompletionResultView(cardFormViewModel: cardFormViewModel)
                    } else if case .loaded = cardFormViewModel.state.authorizedOrderResponse {
                        BrandedCardOrderCompletionResultView(cardFormViewModel: cardFormViewModel)
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
