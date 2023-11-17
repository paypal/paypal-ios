import SwiftUI

struct PayPalWebStatusView: View {

    var status: Status
    var order: Order
    var intent: Intent

    var body: some View {
        VStack(spacing: 16) {
            switch status {
            case .started:
                HStack {
                    Text("Order")
                        .font(.system(size: 20))
                    Spacer()
                }
                LeadingText("Order ID", weight: .bold)
                LeadingText("\(order.id)")
                LeadingText("Status", weight: .bold)
                LeadingText("\(order.status)")
            case .approved:
                HStack {
                    Text("Order Approved")
                        .font(.system(size: 20))
                    Spacer()
                }
                LeadingText("Intent", weight: .bold)
                LeadingText("\(intent)")
                LeadingText("Order ID", weight: .bold)
                LeadingText("\(order.id)")
                LeadingText("Payer ID", weight: .bold)
                //                LeadingText("\(order.payerID)") // TODO: find out where to get this
            case .completed:
                HStack {
                    Text("Order \(intent.rawValue)")
                        .font(.system(size: 20))
                    Spacer()
                }
                LeadingText("Order ID", weight: .bold)
                LeadingText("\(order.id)")
                LeadingText("Status", weight: .bold)
                LeadingText("\(order.status)")
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
