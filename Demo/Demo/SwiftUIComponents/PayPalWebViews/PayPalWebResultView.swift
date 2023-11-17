import SwiftUI

enum Status {
    case started
    case approved
    case completed
}

struct PayPalWebResultView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var status: Status
    var order: Order

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
                LeadingText("\(payPalWebViewModel.state.intent)")
                LeadingText("Order ID", weight: .bold)
                LeadingText("\(order.id)")
                LeadingText("Payer ID", weight: .bold)
//                LeadingText("\(order.payerID)") // TODO: find out where to get this
            case .completed:
                HStack {
                    Text("Order \(payPalWebViewModel.state.intent.rawValue)")
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
