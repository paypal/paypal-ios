import SwiftUI

struct CardApprovalResultView: View {

    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        switch cardPaymentViewModel.state.approveResultResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let approveResultResponse):
            getSuccessView(approveResultResponse: approveResultResponse)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSuccessView(approveResultResponse: CardPaymentState.CardResult) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Card Approval Result")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(approveResultResponse.id)")
            LeadingText("3DS URL", weight: .bold)
            LeadingText("\(approveResultResponse.deepLinkURL ?? "")")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
