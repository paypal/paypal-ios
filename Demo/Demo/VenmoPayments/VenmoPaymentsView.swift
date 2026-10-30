import SwiftUI
import VenmoPayments

struct VenmoPaymentsView: View {
    
    @Environment(VenmoViewModel.self)
    var viewModel
    
    var createOrderState: AsyncState<Order> { viewModel.createOrderState }
    var checkoutState: AsyncState<VenmoCheckoutResult> { viewModel.checkoutState }
    var completeOrderState: AsyncState<Order> { viewModel.completeOrderState }

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
                    AsyncStateView(checkoutState) { venmoCheckoutResult in
                        VenmoCheckoutResultView(result: venmoCheckoutResult)
                        let intent = viewModel.orderIntent
                        CompleteOrderForm(intent: intent, isLoading: completeOrderState.isLoading) {
                            viewModel.completeOrder()
                        }
                    }
                }
            }
        }
        .onOpenURL { url in
            viewModel.handleReturnURL(url)
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

private struct VenmoCheckoutResultView: View {
    
    let result: VenmoCheckoutResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Venmo Checkout Result").font(.headline)
            LabelViewText("Order ID:", bodyText: result.orderID)
            LabelViewText("Payer ID:", bodyText: result.payerID)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(.gray, lineWidth: 2).padding(5))
    }
}
