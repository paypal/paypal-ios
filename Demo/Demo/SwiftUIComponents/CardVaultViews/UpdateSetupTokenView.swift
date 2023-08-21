import SwiftUI

struct UpdateSetupTokenView: View {

    let setupToken: String

    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 25"
    @State private var cvvText: String = "123"

    @ObservedObject var cardVaultViewModel: CardVaultViewModel
    @ObservedObject var baseViewModel: BaseViewModel

    public init(baseViewModel: BaseViewModel, cardVaultViewModel: CardVaultViewModel, setupToken: String) {
        self.cardVaultViewModel = cardVaultViewModel
        self.baseViewModel = baseViewModel
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

            let card = baseViewModel.createCard(
                cardNumber: cardNumberText,
                expirationDate: expirationDateText,
                cvv: cvvText
            )

            ZStack {
                if case .loading = cardVaultViewModel.state.updateSetupTokenResponse {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                }
                Button("Vault Card") {
                    Task {
                        let config = await baseViewModel.getCoreConfig()
                        if let config = config, let card = card {
                            await cardVaultViewModel.vault(
                                config: config,
                                card: card,
                                setupToken: setupToken
                            )
                        } else {
                            DispatchQueue.main.async {
                                cardVaultViewModel.state.updateSetupTokenResponse = .error(message: "Error getting Config or Card")
                            }
                            print("Error getting Config or Card")
                        }
                    }
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue)
            .cornerRadius(10)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
        .padding(5)
    }
}
