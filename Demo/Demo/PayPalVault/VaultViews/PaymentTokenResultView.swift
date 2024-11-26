import SwiftUI

struct PaymentTokenResultView: View {

    @ObservedObject var vaultViewModel: VaultViewModel

    var body: some View {
        switch vaultViewModel.state.paymentTokenResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let paymentTokenResponse):
            getSucessView(paymentTokenResponse: paymentTokenResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSucessView(paymentTokenResponse: PaymentTokenResponse) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Payment Token")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(paymentTokenResponse.id)")
            LeadingText("Customer ID", weight: .bold)
            LeadingText("\(paymentTokenResponse.customer.id)")
            if let card = paymentTokenResponse.paymentSource.card {
                LeadingText("Card Brand", weight: .bold)
                LeadingText("\(card.brand ?? "")")
                LeadingText("Card Last 4", weight: .bold)
                LeadingText("\(card.lastDigits)")
            } else if let paypal = paymentTokenResponse.paymentSource.paypal {
                LeadingText("Email", weight: .bold)
                LeadingText("\(paypal.emailAddress)")
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
