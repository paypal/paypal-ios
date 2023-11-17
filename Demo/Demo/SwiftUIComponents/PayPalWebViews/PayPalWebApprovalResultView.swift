import SwiftUI

struct PayPalWebApprovalResultView: View {

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel

    var body: some View {
        switch paypalWebViewModel.state.orderResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let order):
            PayPalWebResultView(payPalWebViewModel: paypalWebViewModel, status: .approved, order: order)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }
}
