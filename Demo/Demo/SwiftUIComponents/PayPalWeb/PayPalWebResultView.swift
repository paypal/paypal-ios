import SwiftUI

enum OrderStatus {
    case started
    case approved
    case completed
}

struct PayPalWebResultView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var status: OrderStatus

    var body: some View {
        switch payPalWebViewModel.state {
        case .idle, .loading:
            EmptyView()
        case .success:
            PayPalWebStatusView(status: status, payPalViewModel: payPalWebViewModel)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }
}
