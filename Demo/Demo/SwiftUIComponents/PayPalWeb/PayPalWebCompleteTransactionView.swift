import SwiftUI

struct PayPalWebCompleteTransactionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack {
            PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .approved)
            Button("\(payPalWebViewModel.intent.rawValue)") {
                completeTransaction()
            }
            .buttonStyle(RoundedBlueButtonStyle())
            .padding()
            if payPalWebViewModel.state == .loading {
                CircularProgressView()
            }
        }
    }

    private func completeTransaction() {
        Task {
            do {
                try await payPalWebViewModel.completeOrder()
            } catch {
                print("Error capturing order: \(error.localizedDescription)")
            }
        }
    }
}
