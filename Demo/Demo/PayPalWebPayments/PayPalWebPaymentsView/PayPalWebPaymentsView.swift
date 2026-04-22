import SwiftUI

struct PayPalWebPaymentsView: View {
    
    @StateObject var payPalWebViewModel = PayPalWebViewModel()
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    PayPalWebCreateOrderView()
                    if case .loaded = payPalWebViewModel.state.createdOrderResponse {
                        PayPalOrderCreateResultView()
                        PayPalWebButtonsView()
                    }
                    
                    if case .loaded = payPalWebViewModel.state.approveResultResponse {
                        PayPalApprovalResultView()
                        PayPalWebTransactionView()
                            .padding(.bottom, 20)
                    }
                    
                    if case .loaded = payPalWebViewModel.state.capturedOrderResponse {
                        PayPalOrderCompletionResultView()
                    } else if case .loaded = payPalWebViewModel.state.authorizedOrderResponse {
                        PayPalOrderCompletionResultView()
                    }
                    Text("")
                        .id("bottomView")
                }
                .onChange(of: payPalWebViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
                .environmentObject(payPalWebViewModel)
            }
        }
    }
}
