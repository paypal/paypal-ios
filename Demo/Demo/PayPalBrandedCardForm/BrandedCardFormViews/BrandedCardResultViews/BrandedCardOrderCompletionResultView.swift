import SwiftUI

struct BrandedCardOrderCompletionResultView: View {

    @ObservedObject var cardFormViewModel: BrandedCardFormViewModel

    var body: some View {
        VStack {
            if case .loaded(let authorizedOrder) = cardFormViewModel.state.authorizedOrderResponse {
                getCompletionSuccessView(order: authorizedOrder, intent: "Authorized")
            }
            if case .loaded(let capturedOrder) = cardFormViewModel.state.capturedOrderResponse {
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

            if let payerID = cardFormViewModel.checkoutResult?.payerID {
                LabelViewText("Payer ID:", bodyText: payerID)
            }

            if let emailAddress = order.paymentSource?.paypal?.emailAddress {
                LabelViewText("Email:", bodyText: emailAddress)
            }

            if let vaultID = order.paymentSource?.paypal?.attributes?.vault.id {
                LabelViewText("Payment Token:", bodyText: vaultID)
            }

            if let customerID = order.paymentSource?.paypal?.attributes?.vault.customer?.id {
                LabelViewText("Customer ID:", bodyText: customerID)
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
