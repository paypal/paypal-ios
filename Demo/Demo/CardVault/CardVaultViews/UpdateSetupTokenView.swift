import SwiftUI
import CardPayments
import CorePayments

struct UpdateSetupTokenView: View {

    let setupToken: String
    let cardSections: [CardSection] = [
        // source: https://developer.paypal.com/api/rest/sandbox/card-testing/#link-testcardnumbers
        CardSection(title: "Successful Step Up Authentication - Visa", numbers: ["4005 5192 0000 0004"]),
        // source: https://developer.paypal.com/api/rest/sandbox/card-testing/#link-testcardnumbers
        CardSection(title: "Successful Step Up Authentication, LiabilityShift NO  - American Express", numbers: ["371449635398431"]),
        CardSection(title: "Failed Step Up Authentication - Matercard", numbers: ["5131 0160 7884 5457"]),
        CardSection(title: "Frictionless - LiabilityShift Possible", numbers: ["4005 5192 0000 0004"]),
        CardSection(title: "Frictionless - LiabilityShift NO", numbers: ["4020 0278 5185 3235"]),
        CardSection(title: "No Challenge", numbers: ["4111 1111 1111 1111"])
    ]

    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 25"
    @State private var cvvText: String = "123"

    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    public init(cardVaultViewModel: CardVaultViewModel, setupToken: String) {
        self.cardVaultViewModel = cardVaultViewModel
        self.setupToken = setupToken
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Card")
                    .font(.system(size: 20))
                Spacer()
            }

            CardFormView(
                cardSections: cardSections,
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
                Button("Vault Card") {
                    Task {
                        await cardVaultViewModel.vault(card: card, setupToken: setupToken)
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = cardVaultViewModel.state.updateSetupTokenResponse {
                    CircularProgressView()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
