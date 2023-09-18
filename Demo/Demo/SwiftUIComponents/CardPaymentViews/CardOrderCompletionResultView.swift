import SwiftUI

struct CardOrderCompletionResultView: View {

    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        switch cardPaymentViewModel.state.authorizedOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let authorizedOrderResponse):
            getAuthorizeSuccessView(orderResponse: authorizedOrderResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
        
        switch cardPaymentViewModel.state.capturedOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let capturedOrderResponse):
            getCaptureSuccessView(orderResponse: capturedOrderResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getAuthorizeSuccessView(orderResponse: Order) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Authorized")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(orderResponse.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(orderResponse.status)")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }

    func getCaptureSuccessView(orderResponse: Order) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Captured")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(orderResponse.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(orderResponse.status)")
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
