import SwiftUI
import CardPayments

struct PayPalPaymentView: View {
    
    @Environment(PayPalPaymentViewModel.self)
    var viewModel
    
    var isOrderCreationLoading: Bool {
        viewModel.createOrderState.isLoading
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateOrderForm(isLoading: isOrderCreationLoading) { request in
                        viewModel.createOrder(using: request)
                    }
                    if let order = viewModel.createOrderState.value {
                        OrderView(order: order)
                    }
                }
            }
        }
    }
}
