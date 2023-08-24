import SwiftUI

struct PaymentTokenResultView: View {

    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    var body: some View {
        switch cardVaultViewModel.state.paymentTokenResponse {
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
            LeadingText("Card Brand", weight: .bold)
            LeadingText("\(paymentTokenResponse.paymentSource.card.brand ?? "")")
            LeadingText("Card Last 4", weight: .bold)
            LeadingText("\(paymentTokenResponse.paymentSource.card.lastDigits)")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
