import SwiftUI

struct PayPalWebResultView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        switch payPalWebViewModel.state {
        case .idle, .loading:
            EmptyView()
        case .success:
            successView
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    var successView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Details")
                    .font(.system(size: 20))
                Spacer()
            }
            if let orderID = payPalWebViewModel.orderID {
                LeadingText("Order ID", weight: .bold)
                LeadingText("\(orderID)")
            }

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
