import SwiftUI

struct PayPalWebOrderCompletionResultView: View {

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel

    var body: some View {
        switch paypalWebViewModel.state.orderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let order):
            SuccessView(order: order, intent: paypalWebViewModel.state.intent)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }
}
