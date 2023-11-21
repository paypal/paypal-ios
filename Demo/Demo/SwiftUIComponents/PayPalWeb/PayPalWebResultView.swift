import SwiftUI

enum Status {
    case started
    case approved
    case completed
}

struct PayPalWebResultView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var status: Status

    var body: some View {
        switch payPalWebViewModel.state {
        case .idle, .loading:
            EmptyView()
        case .loaded, .success:
            PayPalWebStatusView(status: status, payPalViewModel: payPalWebViewModel)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }
}
