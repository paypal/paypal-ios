import SwiftUI

struct PayPalWebCompleteTransactionView: View {

    let intent: Intent
    let orderID: String

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack {
            PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .approved)
            Button("\(intent.rawValue)") {
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
                try await payPalWebViewModel.completeOrder(with: intent, orderID: orderID)
            } catch {
                print("Error capturing order: \(error.localizedDescription)")
            }
        }
    }
}
