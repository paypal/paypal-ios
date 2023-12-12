import SwiftUI

enum OrderStatusButton: String {
    case created = "Create an Order"
    case approved = "Checkout with PayPal"
    case completed = "Complete Transaction"
}

// TODO: make sure errors are handled
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
                    // TODO: replace state with order status?
                    if payPalWebViewModel.order != nil && payPalWebViewModel.state == .success {
                        PayPalWebButtonsView(payPalWebViewModel: payPalWebViewModel)
                    }

                    if payPalWebViewModel.checkoutResult != nil && payPalWebViewModel.state == .success {
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
