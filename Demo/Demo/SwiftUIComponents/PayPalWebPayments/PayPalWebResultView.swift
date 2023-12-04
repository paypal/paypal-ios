import SwiftUI

enum OrderStatus {
    case created
    case approved
    case completed
}

struct PayPalWebResultView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var status: OrderStatus
    var state: CurrentState {
        switch status {
        case .approved:
            return payPalWebViewModel.approveOrderState
        case .created:
            return payPalWebViewModel.createOrderState
        case .completed:
            return payPalWebViewModel.authorizeCpatureOrderState
        }
    }

    var body: some View {
        switch state {
        case .idle, .loading:
            EmptyView()
        case .success:
            PayPalWebStatusView(status: status, payPalWebViewModel: payPalWebViewModel)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }
}
