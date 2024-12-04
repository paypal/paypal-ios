import SwiftUI

struct PayPalWebPaymentsView: View {
    
    @StateObject var payPalWebViewModel = PayPalWebViewModel()
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    
                    PayPalWebCreateOrderView(payPalWebViewModel: payPalWebViewModel)
                    
                    if case .loaded(let order) = payPalWebViewModel.state.createdOrderResponse {
                        PayPalOrderCreateResultView(payPalWebViewModel: payPalWebViewModel)
                        
                        PayPalWebButtonsView(payPalWebViewModel: payPalWebViewModel)
                    }
                    
                    if case .loaded = payPalWebViewModel.state.approveResultResponse {
                        PayPalApprovalResultView(payPalWebViewModel: payPalWebViewModel)
                        
                        PayPalWebTransactionView(payPalWebViewModel: payPalWebViewModel)
                            .padding(.bottom, 20)
                            .id("bottomView")
                            .onAppear {
                                withAnimation {
                                    scrollView.scrollTo("bottomView")
                                }
                            }
                    }
                    
                    if case .loaded = payPalWebViewModel.state.capturedOrderResponse {
                        PayPalOrderCompletionResultView(payPalWebViewModel: payPalWebViewModel)
                    } else if case .loaded = payPalWebViewModel.state.authorizedOrderResponse {
                        PayPalOrderCreateResultView(payPalWebViewModel: payPalWebViewModel)
                    }
                }
                .onChange(of: payPalWebViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}
