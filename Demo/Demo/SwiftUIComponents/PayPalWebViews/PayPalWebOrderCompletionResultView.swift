import SwiftUI

struct PayPalWebOrderCompletionResultView: View {

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel

    var body: some View {
        switch paypalWebViewModel.state.orderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let orderResponse):
            getOrderSuccessView(orderResponse: orderResponse, intent: paypalWebViewModel.state.intent.rawValue)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getOrderSuccessView(orderResponse: Order, intent: String) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order \(intent)")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(orderResponse.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(orderResponse.status)")
            if let email = orderResponse.paymentSource?.paypal?.emailAddress {
                LeadingText("Email", weight: .bold)
                LeadingText("\(email)")
            }
            Text("")
                .id("bottomView")
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
