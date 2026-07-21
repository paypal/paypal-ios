import SwiftUI

struct PayPalApprovalResultView: View {
    
    @ObservedObject var payPalWebViewModel: PayPalWebViewModel
    
    var body: some View {
        switch payPalWebViewModel.state.approveResultResponse {
        case .idle, .loading:
            EmptyView()
        case .error(let message):
            ErrorView(errorMessage: message)
        case .loaded(let approvalResult):
            getApprovalSuccessView(approvalResult: approvalResult)
        }
    }
    
    func getApprovalSuccessView(approvalResult: PayPalPaymentState.ApprovalResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Approval Result")
                .font(.headline)
            LeadingText("Approval ID", weight: .bold)
                .font(.system(size: 20))
            
            LeadingText(approvalResult.id)
            if let status = approvalResult.status {
                LeadingText("Status", weight: .bold)
                LeadingText(status)
            }
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
