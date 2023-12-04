import SwiftUI

enum OrderStatus {
    case created
    case approved
    case completed
    case error
}

struct PayPalWebResultView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var status: OrderStatus

    var body: some View {
        switch payPalWebViewModel.state {
        case .idle, .loading:
            EmptyView()
        case .success:
            PayPalWebStatusView(status: status, payPalWebViewModel: payPalWebViewModel)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }
}
