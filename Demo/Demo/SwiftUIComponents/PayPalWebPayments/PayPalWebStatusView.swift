import SwiftUI

struct PayPalWebStatusView: View {

    var status: OrderStatus
    var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack(spacing: 16) {
            switch status {
            case .created:
                HStack {
                    Text("Order Created")
                        .font(.system(size: 20))
                    Spacer()
                }
                if let order = payPalWebViewModel.createOrderResult {
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
                if let order = payPalWebViewModel.createOrderResult {
                    LeadingText("Intent", weight: .bold)
                    LeadingText("\(payPalWebViewModel.intent)")
                    LeadingText("Order ID", weight: .bold)
                    LeadingText("\(order.id)")
                    LeadingText("Payer ID", weight: .bold)
                    LeadingText("\(payPalWebViewModel.checkoutResult?.payerID ?? "")")
                }
            case .completed:
                if let order = payPalWebViewModel.transactionResult {
                    HStack {
                        Text("Order \(payPalWebViewModel.intent.rawValue.capitalized)d")
                            .font(.system(size: 20))
                        Spacer()
                    }
                    LeadingText("Order ID", weight: .bold)
                    LeadingText("\(order.id)")
                    LeadingText("Status", weight: .bold)
                    LeadingText("\(order.status)")

                    if let emailAddress = order.paymentSource?.paypal?.emailAddress {
                        LeadingText("Email", weight: .bold)
                        LeadingText("\(emailAddress)")
                    }

                    if let vaultID = order.paymentSource?.paypal?.attributes?.vault.id {
                        LeadingText("Vault ID / Payment Token", weight: .bold)
                        LeadingText("\(vaultID)")
                    }

                    if let customerID = order.paymentSource?.paypal?.attributes?.vault.customer.id {
                        LeadingText("Customer ID", weight: .bold)
                        LeadingText("\(customerID)")
                    }
                }
            default:
                Text("")
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
