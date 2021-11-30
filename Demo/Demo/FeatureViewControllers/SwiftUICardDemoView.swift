import SwiftUI
import PaymentsCore
import Card

@available(iOS 13.0.0, *)
struct SwiftUICardDemo: View {

    // TODO: enable button once all fields are filled out
    // TODO: Update focus to be able to tab from field to field in HStack
    // TODO: Set max character count on text fields

    @State private var cardNumberText: String = ""
    @State private var expirationDateText: String = ""
    @State private var cvvText: String = ""
    @State private var isEnabled = true

    @StateObject var baseViewModel = BaseViewModel()

    let cardFormatter = CardFormatter()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 16) {
                FloatingLabelTextField(placeholder: "Card Number", text: $cardNumberText)
                    .onChange(of: cardNumberText) { newValue in
                        cardNumberText = newValue.replacingOccurrences(of: " ", with: "")
                        cardNumberText = newValue.filter { ("0"..."9").contains($0) }
                        cardNumberText = cardFormatter.formatCardNumber(cardNumberText)
                    }
                HStack(spacing: 16) {
                    FloatingLabelTextField(placeholder: "Expiration Date", text: $expirationDateText)
                        .onChange(of: expirationDateText) { newValue in
                            expirationDateText = newValue.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "")
                            expirationDateText = newValue.filter { ("0"..."9").contains($0) }
                            expirationDateText = cardFormatter.formatExpirationDate(expirationDateText)
                        }
                    FloatingLabelTextField(placeholder: "CVV", text: $cvvText)
                }
                Button("Pay") {
                    isEnabled = isEnabled
                    guard let card = createCard(), let orderID = baseViewModel.orderID else {
                        baseViewModel.updateTitle("Failed: missing card / orderID.")
                        return
                    }

                    checkoutWithCard(card, orderID: orderID)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(isEnabled ? .blue : .gray)
                .cornerRadius(10)
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
                baseViewModel.processOrder(orderID: result.orderID) {
                    // animate button
                }
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
