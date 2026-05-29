import SwiftUI

struct VenmoPaymentsView: View {

    @StateObject var venmoViewModel = VenmoViewModel()

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {

                    VenmoCreateOrderView(venmoViewModel: venmoViewModel)

                    if case .loaded = venmoViewModel.state.createdOrderResponse {
                        VenmoOrderCreateResultView(venmoViewModel: venmoViewModel)

                        VenmoButtonsView(venmoViewModel: venmoViewModel)
                    }

                    if case .loaded = venmoViewModel.state.approveResultResponse {
                        VenmoApprovalResultView(venmoViewModel: venmoViewModel)

                        VenmoTransactionView(venmoViewModel: venmoViewModel)
                            .padding(.bottom, 20)
                    }

                    if case .loaded = venmoViewModel.state.capturedOrderResponse {
                        VenmoOrderCompletionResultView(venmoViewModel: venmoViewModel)
                    } else if case .loaded = venmoViewModel.state.authorizedOrderResponse {
                        VenmoOrderCompletionResultView(venmoViewModel: venmoViewModel)
                    }
                    Text("")
                        .id("bottomView")
                }
                .onChange(of: venmoViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}
