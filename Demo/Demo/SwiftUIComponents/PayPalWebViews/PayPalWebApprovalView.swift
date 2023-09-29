import SwiftUI

struct PayPalWebApprovalView: View {

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel

    var body: some View {
        switch paypalWebViewModel.state.checkoutResultResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let checkoutResponse):
            getCheckoutSuccessView(checkoutResult: checkoutResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getCheckoutSuccessView(checkoutResult: PayPalWebState.CheckoutResult) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Approved")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Intent", weight: .bold)
            LeadingText("\(paypalWebViewModel.state.intent)")
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(checkoutResult.id)")
            LeadingText("Payer ID", weight: .bold)
            LeadingText("\(checkoutResult.payerID)")
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
