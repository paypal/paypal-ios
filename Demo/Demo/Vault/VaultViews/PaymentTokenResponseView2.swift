import SwiftUI
import CardPayments
import CorePayments

struct PaymentTokenResponseView2: View {

    let response: PaymentTokenResponse

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Payment Token")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(response.id)")
            LeadingText("Customer ID", weight: .bold)
            LeadingText("\(response.customer.id)")
            if let card = response.paymentSource.card {
                LeadingText("Card Brand", weight: .bold)
                LeadingText("\(card.brand ?? "")")
                LeadingText("Card Last 4", weight: .bold)
                LeadingText("\(card.lastDigits)")
            } else if let paypal = response.paymentSource.paypal {
                LeadingText("Email", weight: .bold)
                LeadingText("\(paypal.emailAddress)")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
