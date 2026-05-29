import SwiftUI

struct VenmoOrderCompletionResultView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    var body: some View {
        VStack {
            if case .loaded(let authorizedOrder) = venmoViewModel.state.authorizedOrderResponse {
                getCompletionSuccessView(order: authorizedOrder, intent: "Authorized")
            }
            if case .loaded(let capturedOrder) = venmoViewModel.state.capturedOrderResponse {
                getCompletionSuccessView(order: capturedOrder, intent: "Captured")
            }
        }
    }

    func getCompletionSuccessView(order: Order, intent: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order \(intent) Successfully")
                .font(.system(size: 20))

            LabelViewText("Order ID:", bodyText: order.id)

            LabelViewText("Status:", bodyText: order.status)

            if let payerID = venmoViewModel.checkoutResult?.payerID {
                LabelViewText("Payer ID:", bodyText: payerID)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
