import SwiftUI

struct PayPalWebCompleteTransactionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack(spacing: 16) {
            PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .approved)
            ZStack {
                Button("\(payPalWebViewModel.intent.rawValue)") {
                    completeTransaction()
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if payPalWebViewModel.state == .loading {
                    CircularProgressView()
                }
            }
            .padding()

            if payPalWebViewModel.state == .success {
                PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .completed)
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
