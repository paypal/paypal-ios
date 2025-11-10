import SwiftUI

struct PayPalWebPaymentsView: View {
    
    @StateObject var payPalWebViewModel = PayPalWebViewModel()
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    
                    PayPalWebCreateOrderView(payPalWebViewModel: payPalWebViewModel)
                    
                    if case .loaded = payPalWebViewModel.state.createdOrderResponse {
                        PayPalOrderCreateResultView(payPalWebViewModel: payPalWebViewModel)
                        
                        PayPalWebButtonsView(payPalWebViewModel: payPalWebViewModel)
                    }
                    
                    if case .loaded = payPalWebViewModel.state.approveResultResponse {
                        PayPalApprovalResultView(payPalWebViewModel: payPalWebViewModel)
                        
                        PayPalWebTransactionView(payPalWebViewModel: payPalWebViewModel)
                            .padding(.bottom, 20)
                    }
                    
                    if case .loaded = payPalWebViewModel.state.capturedOrderResponse {
                        PayPalOrderCompletionResultView(payPalWebViewModel: payPalWebViewModel)
                    } else if case .loaded = payPalWebViewModel.state.authorizedOrderResponse {
                        PayPalOrderCompletionResultView(payPalWebViewModel: payPalWebViewModel)
                    }
                    Text("")
                        .id("bottomView")
                }
                .onChange(of: payPalWebViewModel.state) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
        .onOpenURL { url in
            // for testing, this will be moved to app level with singleton router
            print("returned url: \(url.absoluteString)")
            print("placeholder for breakpoint")
            payPalWebViewModel.handleUniversalLinkReturn(url)
        }
    }
}
