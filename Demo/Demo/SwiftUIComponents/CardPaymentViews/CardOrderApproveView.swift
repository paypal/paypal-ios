import SwiftUI
import CardPayments
import CorePayments

struct CardOrderApproveView: View {

    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 25"
    @State private var cvvText: String = "123"
    let orderID: String
    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                HStack {
                    Text("Enter Card Information")
                        .font(.system(size: 20))
                    Spacer()
                }

                CardFormView(
                    cardNumberText: $cardNumberText,
                    expirationDateText: $expirationDateText,
                    cvvText: $cvvText
                )

                let card = Card.createCard(
                    cardNumber: cardNumberText,
                    expirationDate: expirationDateText,
                    cvv: cvvText
                )

                ZStack {
                    Button("Approve Order") {
                        Task {
                            do {
                                await cardPaymentViewModel.checkoutWith(card: card, orderID: orderID)
                            }
                        }
                    }
                    .buttonStyle(RoundedBlueButtonStyle())
                    if case .loading = cardPaymentViewModel.state.approveResultResponse {
                        CircularProgressView()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 2)
                    .padding(5)
            )
            CardApprovalResultView(cardPaymentViewModel: cardPaymentViewModel)
            Spacer()
        }
        if cardPaymentViewModel.state.approveResult != nil {
            NavigationLink {
                CardPaymentOrderCompletionView(orderID: orderID, cardPaymentViewModel: cardPaymentViewModel)
            } label: {
                Text("Complete Order Transaction")
            }
            .buttonStyle(RoundedBlueButtonStyle())
            .padding()
        }
    }
}
