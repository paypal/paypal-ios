import SwiftUI

struct PayPalOrderActionButton: View {

    let intent: Intent
    let orderID: String
    let selectedMerchantIntegration: MerchantIntegration

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack {
            if payPalWebViewModel.state == .loading {
                CircularProgressView()
            } else if payPalWebViewModel.state == .loaded {
                PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .approved)
            }

            Button("\(intent.rawValue)") {
                completeOrder()
            }
            .buttonStyle(RoundedBlueButtonStyle())
            .padding()
        }
    }

    private func completeOrder() {
        Task {
            do {
                try await payPalWebViewModel.completeOrder(
                    with: intent,
                    orderID: orderID,
                    selectedMerchantIntegration: selectedMerchantIntegration
                )
            } catch {
                print("Error capturing order: \(error.localizedDescription)")
            }
        }
    }
}
