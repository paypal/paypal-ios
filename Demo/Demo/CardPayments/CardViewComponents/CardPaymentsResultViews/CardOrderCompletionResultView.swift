import SwiftUI

struct CardOrderCompletionResultView: View {

    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        switch cardPaymentViewModel.state.authorizedOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let authorizedOrderResponse):
            getOrderSuccessView(orderResponse: authorizedOrderResponse, intent: "Authorized")
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }

        switch cardPaymentViewModel.state.capturedOrderResponse {
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
            if let lastDigits = orderResponse.paymentSource?.card?.lastDigits {
                LeadingText("Card Last Digits", weight: .bold)
                LeadingText("\(lastDigits)")
            }
            if let brand = orderResponse.paymentSource?.card?.brand {
                LeadingText("Brand", weight: .bold)
                LeadingText("\(brand)")
            }
            if let vaultStatus = orderResponse.paymentSource?.card?.attributes?.vault.status {
                LeadingText("Vault Status", weight: .bold)
                LeadingText("\(vaultStatus)")
            }
            if let vaultID = orderResponse.paymentSource?.card?.attributes?.vault.id {
                LeadingText("Vault ID / Payment Token", weight: .bold)
                LeadingText("\(vaultID)")
            }
            if let customerID = orderResponse.paymentSource?.card?.attributes?.vault.customer?.id {
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
