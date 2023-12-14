import SwiftUI

struct PayPalWebPaymentsView: View {

    @StateObject var payPalWebViewModel = PayPalWebViewModel()

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    PayPalWebCreateOrderView(payPalWebViewModel: payPalWebViewModel)

                    if payPalWebViewModel.orderID != nil {
                        PayPalWebButtonsView(payPalWebViewModel: payPalWebViewModel)
                    }

                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel)

                    if payPalWebViewModel.checkoutResult != nil {
                        PayPalWebTransactionView(payPalWebViewModel: payPalWebViewModel)
                            .id("bottomView")
                            .onAppear {
                                withAnimation {
                                    scrollView.scrollTo("bottomView")
                                }
                            }
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
