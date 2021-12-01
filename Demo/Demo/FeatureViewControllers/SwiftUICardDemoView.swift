import SwiftUI
import PaymentsCore
import Card

@available(iOS 13.0.0, *)
struct SwiftUICardDemo: View {

    @State private var cardNumberText: String = ""
    @State private var expirationDateText: String = ""
    @State private var cvvText: String = ""

    @StateObject var baseViewModel = BaseViewModel()

    let cardFormatter = CardFormatter()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 16) {
                FloatingLabelTextField(placeholder: "Card Number", text: $cardNumberText)
                    .onChange(of: cardNumberText) { newValue in
                        let cleanedText = newValue.replacingOccurrences(of: " ", with: "")
                        cardNumberText = String(cleanedText.prefix(CardType.unknown.getCardType(cardNumberText).maxLength))
                        cardNumberText = cardNumberText.filter { ("0"..."9").contains($0) }
                        cardNumberText = cardFormatter.formatCardNumber(cardNumberText)
                    }
                FloatingLabelTextField(placeholder: "Expiration Date", text: $expirationDateText)
                    .onChange(of: expirationDateText) { newValue in
                        let cleanedText = newValue.replacingOccurrences(of: " / ", with: "")
                        expirationDateText = String(cleanedText.prefix(4))
                        expirationDateText = expirationDateText.filter { ("0"..."9").contains($0) }
                        expirationDateText = cardFormatter.formatExpirationDate(expirationDateText)
                    }
                FloatingLabelTextField(placeholder: "CVV", text: $cvvText)
                    .onChange(of: cvvText) { newValue in
                        cvvText = String(newValue.prefix(4))
                        cvvText = cvvText.filter { ("0"..."9").contains($0) }
                    }
                Button("Pay") {
                    guard let card = createCard(), let orderID = baseViewModel.orderID else {
                        baseViewModel.updateTitle("Failed: missing card / orderID.")
                        return
                    }

                    checkoutWithCard(card, orderID: orderID)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(10)
                .disabled(!(cvvText.count >= 3 && cardNumberText.count >= 17 && expirationDateText.count == 7))
            }
            .padding(.horizontal, 16)
        }
    }

    func checkoutWithCard(_ card: Card, orderID: String) {
        let config = CoreConfig(clientID: DemoSettings.clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
        let cardClient = CardClient(config: config)

        cardClient.approveOrder(orderID: orderID, card: card) { result in
            switch result {
            case .success(let result):
                print(result)
                baseViewModel.updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: APPROVED")
                baseViewModel.processOrder(orderID: result.orderID)
            case .failure(let error):
                print(error)
                baseViewModel.updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
            }
        }
    }

    private func createCard() -> Card? {
        let cleanedCardText = cardNumberText.replacingOccurrences(of: " ", with: "")

        let expirationComponents = expirationDateText.components(separatedBy: " / ")
        let expirationMonth = expirationComponents[0]
        let expirationYear = "20" + expirationComponents[1]

        return Card(number: cleanedCardText, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: cvvText)
    }
}

@available(iOS 13.0.0, *)
struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        SwiftUICardDemo(baseViewModel: BaseViewModel())
    }
}
