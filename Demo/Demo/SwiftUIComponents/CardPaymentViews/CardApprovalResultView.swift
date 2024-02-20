import SwiftUI

struct CardApprovalResultView: View {

    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        switch cardPaymentViewModel.state.approveResultResponse {
        case .idle, .loading:
            EmptyView()
        case .loaded(let approvalResult):
            getSuccessView(approvalResult: approvalResult)
        case .error(let errorMessage):
            ErrorView(errorMessage: errorMessage)
        }
    }

    func getSuccessView(approvalResult: CardPaymentState.CardResult) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Card Approval Result")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(approvalResult.id)")
            if let status = approvalResult.status {
                LeadingText("Order Status", weight: .bold)
                LeadingText("\(status)")
            }
            LeadingText("didAttemptThreeDSecureAuthentication", weight: .bold)
            LeadingText("\(approvalResult.didAttemptThreeDSecureAuthentication)")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
