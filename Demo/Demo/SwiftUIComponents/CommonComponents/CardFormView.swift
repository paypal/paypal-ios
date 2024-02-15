import SwiftUI

struct CardSection: Identifiable {

    let id = UUID()
    let title: String
    let numbers: [String]
}

struct CardFormView: View {

    let cardSections: [CardSection]
    private let cardFormatter = CardFormatter()

    @Binding var cardNumberText: String
    @Binding var expirationDateText: String
    @Binding var cvvText: String

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                FloatingLabelTextField(placeholder: "Card Number", text: $cardNumberText)
                    .onChange(of: cardNumberText) { newValue in
                        cardNumberText = cardFormatter.formatFieldWith(newValue, field: .cardNumber)
                        // 4 digit cvv for amex
                        cvvText = CardType.unknown.getCardType(newValue) == .americanExpress ? "1234" : "123"
                    }
                if !cardSections.isEmpty {
                    Menu {
                        ForEach(cardSections, id: \.self.title) { section in
                            Section(header: Text(section.title)) {
                                ForEach(section.numbers, id: \.self) { number in
                                    Button(number) {
                                        cardNumberText = number
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "chevron.down.circle")
                    }
                }
            }
            FloatingLabelTextField(placeholder: "Expiration Date", text: $expirationDateText)
                .onChange(of: expirationDateText) { newValue in
                    expirationDateText = cardFormatter.formatFieldWith(newValue, field: .expirationDate)
                }
            FloatingLabelTextField(placeholder: "CVV", text: $cvvText)
                .onChange(of: cvvText) { newValue in
                    cvvText = cardFormatter.formatFieldWith(newValue, field: .cvv)
                }
        }
    }
}

struct CardFormView_Previews: PreviewProvider {

    @State static var mockCardNumberText: String = "41111111111111111"
    @State static var mockExpirationDateText: String = "01/25"
    @State static var mockCvvText: String = "123"
    static let cardData: [CardSection] = [
        CardSection(title: "Step up", numbers: ["1234 5678 9012 3456"]),
        CardSection(title: "Frictionless", numbers: ["3456 6789 0123 4567"])
    ]

    static var previews: some View {
        CardFormView(
            cardSections: cardData,
            cardNumberText: $mockCardNumberText,
            expirationDateText: $mockExpirationDateText,
            cvvText: $mockCvvText
        )
    }
}
