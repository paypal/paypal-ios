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
        case .loaded(let order):
            // TODO: figure out sending intent
            PayPalWebStatusView(status: status, order: order, intent: .authorize)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }
}
