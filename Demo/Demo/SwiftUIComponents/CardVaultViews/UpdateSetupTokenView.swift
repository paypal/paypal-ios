import SwiftUI
import CardPayments
import CorePayments

struct UpdateSetupTokenView: View {

    let setupToken: String

    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 25"
    @State private var cvvText: String = "123"

    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    let cardSections: [CardSection] = [
        CardSection(title: "Step up", numbers: ["5314 6090 4083 0349"]),
        CardSection(title: "Frictionless - LiabilityShift Possible", numbers: ["4005 5192 0000 0004"]),
        CardSection(title: "Frictionless - LiabilityShift NO", numbers: ["4020 0278 5185 3235"]),
        CardSection(title: "No Challenge", numbers: ["4111 1111 1111 1111"])
    ]

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
                cardNumberText: $cardNumberText,
                expirationDateText: $expirationDateText,
                cvvText: $cvvText,
                cardSections: cardSections
            )

            let card = Card.createCard(
                cardNumber: cardNumberText,
                expirationDate: expirationDateText,
                cvv: cvvText
            )

            ZStack {
                Button("Vault Card") {
                    Task {
                        await cardVaultViewModel.vault(
                            card: card,
                            setupToken: setupToken
                        )
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
                .stroke(Color.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
