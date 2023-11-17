import SwiftUI

struct SuccessView: View {

    var order: Order
    var intent: Intent

    init(order: Order, intent: Intent) {
        self.order = order
        self.intent = intent
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order \(intent.rawValue)")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(order.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(order.status)")
            if let email = order.paymentSource?.paypal?.emailAddress {
                LeadingText("Email", weight: .bold)
                LeadingText("\(email)")
            }
            Text("")
                .id("bottomView")
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
