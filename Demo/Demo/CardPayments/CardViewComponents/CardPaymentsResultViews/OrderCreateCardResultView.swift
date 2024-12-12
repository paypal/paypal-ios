import SwiftUI

struct OrderCreateCardResultView: View {

    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        switch cardPaymentViewModel.state.createdOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let createOrderResponse):
            getSuccessView(createOrderResponse: createOrderResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSuccessView(createOrderResponse: Order) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(createOrderResponse.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(createOrderResponse.status)")
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
