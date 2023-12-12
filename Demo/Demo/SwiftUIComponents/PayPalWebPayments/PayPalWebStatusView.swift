import SwiftUI

struct PayPalWebStatusView: View {

    var status: OrderStatus
    var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Details")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(payPalWebViewModel.createOrderResult?.id ?? "")")

            if let status = payPalWebViewModel.order?.status {
                LeadingText("Status", weight: .bold)
                LeadingText("\(status)")
            }

            if let payerID = payPalWebViewModel.checkoutResult?.payerID {
                LeadingText("Payer ID", weight: .bold)
                LeadingText("\(payerID)")
            }

            if let emailAddress = payPalWebViewModel.order?.paymentSource?.paypal?.emailAddress {
                LeadingText("Email", weight: .bold)
                LeadingText("\(emailAddress)")
            }

            if let vaultID = payPalWebViewModel.order?.paymentSource?.paypal?.attributes?.vault.id {
                LeadingText("Vault ID / Payment Token", weight: .bold)
                LeadingText("\(vaultID)")
            }

            if let customerID = payPalWebViewModel.order?.paymentSource?.paypal?.attributes?.vault.customer.id {
                LeadingText("Customer ID", weight: .bold)
                LeadingText("\(customerID)")
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
