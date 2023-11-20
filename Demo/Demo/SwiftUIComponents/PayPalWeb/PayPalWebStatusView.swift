import SwiftUI

struct PayPalWebStatusView: View {

    var status: Status
    var intent: Intent
    var payPalViewModel: PayPalWebViewModel

    var body: some View {
        VStack(spacing: 16) {
            switch status {
            case .started:
                HStack {
                    Text("Order Created")
                        .font(.system(size: 20))
                    Spacer()
                }
                if let order = payPalViewModel.order {
                    LeadingText("Order ID", weight: .bold)
                    LeadingText("\(order.id)")
                    LeadingText("Status", weight: .bold)
                    LeadingText("\(order.status)")
                }
            case .approved:
                HStack {
                    Text("Order Approved")
                        .font(.system(size: 20))
                    Spacer()
                }
                if let order = payPalViewModel.order {
                    LeadingText("Intent", weight: .bold)
                    LeadingText("\(intent)")
                    LeadingText("Order ID", weight: .bold)
                    LeadingText("\(order.id)")
                    LeadingText("Payer ID", weight: .bold)
                    LeadingText("\(payPalViewModel.checkoutResult?.payerID ?? "")")
                }
            case .completed:
                if let order = payPalViewModel.order {
                    HStack {
                        Text("Order \(intent.rawValue.lowercased())")
                            .font(.system(size: 20))
                        Spacer()
                    }
                    LeadingText("Order ID", weight: .bold)
                    LeadingText("\(order.id)")
                    LeadingText("Status", weight: .bold)
                    LeadingText("\(order.status)")
                }
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
