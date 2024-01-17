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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Order Details")
                    .font(.system(size: 20))
                Spacer()
            }
            if let orderID = payPalWebViewModel.orderID {
                LabelViewText("Order ID:", bodyText: orderID)
            }

            if let status = payPalWebViewModel.order?.status {
                LabelViewText("Status:", bodyText: status)
            }

            if let payerID = payPalWebViewModel.checkoutResult?.payerID {
                LabelViewText("Payer ID:", bodyText: payerID)
            }

            if let emailAddress = payPalWebViewModel.order?.paymentSource?.paypal?.emailAddress {
                LabelViewText("Email:", bodyText: emailAddress)
            }

            if let vaultID = payPalWebViewModel.order?.paymentSource?.paypal?.attributes?.vault.id {
                LabelViewText("Payment Token:", bodyText: vaultID)
            }

            if let customerID = payPalWebViewModel.order?.paymentSource?.paypal?.attributes?.vault.customer.id {
                LabelViewText("Customer ID:", bodyText: customerID)
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
