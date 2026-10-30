import SwiftUI

struct VenmoPaymentsView: View {
    
    @Environment(VenmoViewModel.self)
    var viewModel
    
    var createOrderState: AsyncState<Order> { viewModel.createOrderState }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateOrderForm(
                        isLoading: createOrderState.isLoading,
                        shouldOfferVaultWithPurchase: false
                    ) { request in
                        viewModel.createOrder(using: request)
                    }
                    AsyncStateView(createOrderState) { order in
                        OrderView(order: order)
                    }
                }
            }
        }
    }
}
