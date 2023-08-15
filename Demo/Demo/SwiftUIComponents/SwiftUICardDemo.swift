import SwiftUI

/// This view contains the exact same behavior as our `CardDemoViewController` but uses SwiftUI best practices to create the card fields and buttons.
/// Under the hood they both do the same thing but this represents how a merchant would use the card module with a Swift UI integration.
struct SwiftUICardDemo: View {

    // MARK: Variables

    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 25"
    @State private var cvvText: String = "123"
    @State private var vaultCustomerID: String = ""
    @State var shouldVaultSelected = false

    @StateObject var baseViewModel = BaseViewModel()

    private let cardFormatter = CardFormatter()

    // MARK: Views

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 16) {
                CardFormView(cardNumberText: $cardNumberText, expirationDateText: $expirationDateText, cvvText: $cvvText)
                HStack {
                    Toggle("Should Vault", isOn: $shouldVaultSelected)
                    Spacer()
                }
                if shouldVaultSelected {
                    FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $vaultCustomerID)
                }
                Button("\(DemoSettings.intent.rawValue.capitalized) Order") {
                    guard let card = baseViewModel.createCard(
                        cardNumber: cardNumberText,
                        expirationDate: expirationDateText,
                        cvv: cvvText
                    ),
                        let orderID = baseViewModel.orderID
                    else {
                        return
                    }

                    Task {
                        await baseViewModel.checkoutWith(
                            card: card,
                            orderID: orderID
                        )
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    baseViewModel.isCardFormValid(cardNumber: cardNumberText, expirationDate: expirationDateText, cvv: cvvText)
                    ? .blue
                    : .gray
                )
                .cornerRadius(10)
                .disabled(!baseViewModel.isCardFormValid(cardNumber: cardNumberText, expirationDate: expirationDateText, cvv: cvvText))
            }
            .padding(.horizontal, 16)
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        SwiftUICardDemo(shouldVaultSelected: true, baseViewModel: BaseViewModel())
    }
}
