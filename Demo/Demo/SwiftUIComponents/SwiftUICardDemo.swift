import SwiftUI

/// This view contains the exact same behavior as our `CardDemoViewController` but uses SwiftUI best practices to create the card fields and buttons.
/// Under the hood they both do the same thing but this represents how a merchant would use the card module with a Swift UI integration.
struct SwiftUICardDemo: View {

    // MARK: Variables

    @State private var cardNumberText: String = ""
    @State private var expirationDateText: String = ""
    @State private var cvvText: String = ""
    @State private var vaultCustomerID: String = ""
    @State var shouldVaultSelected = false

    @StateObject var baseViewModel = BaseViewModel()

    private let cardFormatter = CardFormatter()

    // MARK: Views

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 16) {
                FloatingLabelTextField(placeholder: "Card Number", text: $cardNumberText)
                    .onChange(of: cardNumberText) { newValue in
                        cardNumberText = cardFormatter.formatFieldWith(newValue, field: .cardNumber)
                    }
                FloatingLabelTextField(placeholder: "Expiration Date", text: $expirationDateText)
                    .onChange(of: expirationDateText) { newValue in
                        expirationDateText = cardFormatter.formatFieldWith(newValue, field: .expirationDate)
                    }
                FloatingLabelTextField(placeholder: "CVV", text: $cvvText)
                    .onChange(of: cvvText) { newValue in
                        cvvText = cardFormatter.formatFieldWith(newValue, field: .cvv)
                    }
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
                            orderID: orderID,
                            shouldVault: shouldVaultSelected,
                            customerID: vaultCustomerID.isEmpty ? nil : vaultCustomerID
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
