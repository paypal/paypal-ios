import SwiftUI

struct PayPalOrderCreateResultView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        switch payPalWebViewModel.state.createdOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let createOrderResponse):
            getSuccessView(createOrderResponse: createOrderResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSuccessView(createOrderResponse: Order) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Order Details")
                    .font(.system(size: 20))
                Spacer()
            }
            
            LabelViewText("Order ID:", bodyText: createOrderResponse.id)
            
            LabelViewText("Status:", bodyText: createOrderResponse.status)

            if let payerID = payPalWebViewModel.checkoutResult?.payerID {
                LabelViewText("Payer ID:", bodyText: payerID)
            }

            if let emailAddress = createOrderResponse.paymentSource?.paypal?.emailAddress {
                LabelViewText("Email:", bodyText: emailAddress)
            }

            if let vaultID = createOrderResponse.paymentSource?.paypal?.attributes?.vault.id {
                LabelViewText("Payment Token:", bodyText: vaultID)
            }

            if let customerID = createOrderResponse.paymentSource?.paypal?.attributes?.vault.customer?.id {
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
