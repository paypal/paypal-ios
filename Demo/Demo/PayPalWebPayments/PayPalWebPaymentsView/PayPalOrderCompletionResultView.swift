import SwiftUI

struct PayPalOrderCompletionResultView: View {
    @ObservedObject var payPalWebViewModel: PayPalWebViewModel
    
    var body: some View {
        VStack {
            if case .loaded(let authorizedOrder) = payPalWebViewModel.state.authorizedOrderResponse {
                getCompletionSuccessView(order: authorizedOrder, intent: "Authorized")
            }
            if case .loaded(let capturedOrder) = payPalWebViewModel.state.capturedOrderResponse {
                getCompletionSuccessView(order: capturedOrder, intent: "Captured")
            }
        }
    }
    
    func getCompletionSuccessView(order: Order, intent: String) -> some View {
        VStack(spacing: 16) {
            Text("Order \(intent) Successfully")
                .font(.headline)
            
            LeadingText("Order ID", weight: .bold)
            LeadingText(order.id)
            LeadingText("Status", weight: .bold)
            LeadingText(order.status)
        }
    }
}
