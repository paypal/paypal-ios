import SwiftUI

// TODO: maybe transaction view
struct PayPalWebOrderCompletionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .approved)
                    
                    if payPalWebViewModel.checkoutResult != nil {
                        PayPalWebCompleteTransactionView(payPalWebViewModel: payPalWebViewModel)
                    }

                    if payPalWebViewModel.state == .success {
                        PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .completed)
                    }
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
