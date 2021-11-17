import SwiftUI

@available(iOS 13.0.0, *)
struct SwiftUICardDemo: View {

    @State private var cardNumberText: String = ""
    @State private var expirationDateText: String = ""
    @State private var cvvText: String = ""

    @State private var isEnabled = false
    
    private let cardFormatter = CardFormatter()

    var body: some View {
        ZStack {
            SwiftUIRepresentable()
            VStack(spacing: 16) {
                FloatingLabelTextField(placeholder: "Card Number", text: $cardNumberText)
                HStack(spacing: 16) {
                    FloatingLabelTextField(placeholder: "Expiration Date", text: $expirationDateText)
                    FloatingLabelTextField(placeholder: "CVV", text: $cvvText)
                }
                Button("Pay") {
                    isEnabled = isEnabled
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
}

@available(iOS 13.0.0, *)
struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        SwiftUICardDemo()
    }
}
