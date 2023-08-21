import SwiftUI

struct PaymentTokenResultView: View {

    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    var body: some View {
        switch cardVaultViewModel.state.paymentTokenResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let paymentTokenResponse):
            getSucessView(paymentTokenResponse: paymentTokenResponse)
        case .error(let message):
            ErrorView(errorText: message)
        }
    }

    func getSucessView(paymentTokenResponse: PaymentTokenResponse) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Payment Token")
                    .font(.system(size: 20))
                Spacer()
            }
            Text("ID")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(paymentTokenResponse.id)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Customer ID")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(paymentTokenResponse.customer.id)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Card Brand")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(paymentTokenResponse.paymentSource.card.brand ?? "")")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Card Last 4")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(paymentTokenResponse.paymentSource.card.lastDigits)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
        .padding(5)
    }
}
