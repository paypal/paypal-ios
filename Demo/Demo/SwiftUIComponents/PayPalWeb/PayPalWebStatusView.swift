import SwiftUI

struct PayPalWebStatusView: View {

    var status: Status
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
                    LeadingText("\(payPalViewModel.intent)")
                    LeadingText("Order ID", weight: .bold)
                    LeadingText("\(order.id)")
                    LeadingText("Payer ID", weight: .bold)
                    LeadingText("\(payPalViewModel.checkoutResult?.payerID ?? "")")
                }
            case .completed:
                if let order = payPalViewModel.order {
                    HStack {
                        Text("Order \(payPalViewModel.intent.rawValue.capitalized)d")
                            .font(.system(size: 20))
                        Spacer()
                    }
                    LeadingText("Order ID", weight: .bold)
                    LeadingText("\(order.id)")
                    LeadingText("Status", weight: .bold)
                    LeadingText("\(order.status)")

                    if let emailAddress = payPalViewModel.order?.paymentSource?.paypal?.emailAddress {
                        LeadingText("Email", weight: .bold)
                        LeadingText("\(emailAddress)")
                    }
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
