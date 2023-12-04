import SwiftUI

struct PayPalWebResultView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        switch payPalWebViewModel.state {
        case .idle, .loading:
            EmptyView()
        case .orderSuccess, .orderApproved, .transactionSuccess:
            PayPalWebStatusView(payPalWebViewModel: payPalWebViewModel)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }
}
