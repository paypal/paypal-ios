import SwiftUI

struct PayPalWebOrderCompletionResultView: View {

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel

    var body: some View {
        switch paypalWebViewModel.state.authorizedOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let authorizedOrderResponse):
            getOrderSuccessView(orderResponse: authorizedOrderResponse, intent: "Authorized")
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }

        switch paypalWebViewModel.state.capturedOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let capturedOrderResponse):
            getOrderSuccessView(orderResponse: capturedOrderResponse, intent: "Captured")
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getOrderSuccessView(orderResponse: Order, intent: String) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order \(intent)")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(orderResponse.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(orderResponse.status)")
            if let email = orderResponse.paymentSource?.paypal?.emailAddress {
                LeadingText("Email", weight: .bold)
                LeadingText("\(email)")
            }
            if let vaultID = orderResponse.paymentSource?.paypal?.attributes?.vault.id {
                LeadingText("Vault ID / Payment Token", weight: .bold)
                LeadingText("\(vaultID)")
            }
            if let customerID = orderResponse.paymentSource?.paypal?.attributes?.vault.customer.id {
                LeadingText("Customer ID", weight: .bold)
                LeadingText("\(customerID)")
            }
            Text("")
                .id("bottomView")
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
