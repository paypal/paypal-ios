import SwiftUI
import CardPayments
import CorePayments

struct UpdateSetupTokenView: View {

    let setupToken: String

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
                        let config = CoreConfig(clientID: DemoSettings.clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
                        await cardVaultViewModel.vault(
                            config: config,
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
