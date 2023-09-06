import SwiftUI

struct OrderCompletionResultView: View {
    
    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    var body: some View {
        switch cardVaultViewModel.state.authorizedOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let authorizedOrderResponse):
            getAuthorizeSuccessView(authorizedOrderResponse: authorizedOrderResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
        switch cardVaultViewModel.state.capturedOrderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let capturedOrderResponse):
            getCaptureSuccessView(capturedOrderResponse: capturedOrderResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getAuthorizeSuccessView(authorizedOrderResponse: Order) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Authorized")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(authorizedOrderResponse.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(authorizedOrderResponse.status)")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)
                .padding(5)
        )
    }

    func getCaptureSuccessView(capturedOrderResponse: Order) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Order Captured")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("Order ID", weight: .bold)
            LeadingText("\(capturedOrderResponse.id)")
            LeadingText("Status", weight: .bold)
            LeadingText("\(capturedOrderResponse.status)")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
