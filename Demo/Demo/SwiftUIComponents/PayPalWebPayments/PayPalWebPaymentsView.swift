import SwiftUI

// TODO: pin result view to bottom
// TODO: hide order create view after order created
// TODO: scrollview not working as expected
// TODO: add reset button

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

                    if payPalWebViewModel.checkoutResult != nil {
                        PayPalWebTransactionView(payPalWebViewModel: payPalWebViewModel)
                    }

                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel)
                        .id("bottomView")
                }
                .onChange(of: payPalWebViewModel.order) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
            }
        }
    }
}
