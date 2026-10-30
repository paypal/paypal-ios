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
                        ApproveOrderWithVenmoForm(isLoading: false) {
                            viewModel.startVenmoCheckout()
                        }
                    }
                }
            }
        }
    }
}

struct ApproveOrderWithVenmoForm: View {
    
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        FormGroup {
            Text("Checkout with Venmo")
                .font(.subheadline)
                .foregroundColor(.primary)
            ButtonWithProgress(label: "Checkout with Venmo", isLoading: isLoading) {
                onSubmit()
            }
        }
    }
}
