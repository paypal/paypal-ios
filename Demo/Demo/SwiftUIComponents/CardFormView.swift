import SwiftUI

struct CardFormView: View {

    @Binding var cardNumberText: String
    @Binding var expirationDateText: String
    @Binding var cvvText: String

    private let cardFormatter = CardFormatter()

    var body: some View {
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
        }
    }
}

struct CardFormView_Previews: PreviewProvider {
    
    @State static var mockCardNumberText: String = ""
    @State static var mockExpirationDateText: String = ""
    @State static var mockCvvText: String = ""

    static var previews: some View {
        CardFormView(
            cardNumberText: $mockCardNumberText,
            expirationDateText: $mockExpirationDateText,
            cvvText: $mockCvvText
        )
    }
}
