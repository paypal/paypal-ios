import SwiftUI

struct PayPalOrderActionButton: View {

    let intent: Intent
    let orderID: String
    let selectedMerchantIntegration: MerchantIntegration

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel

    var body: some View {
        ZStack {
            Button("\(intent.rawValue)") {
                completeOrder()
            }
            .buttonStyle(RoundedBlueButtonStyle())
            .padding()

            if .loading == paypalWebViewModel.state.authorizedOrderResponse ||
                .loading == paypalWebViewModel.state.capturedOrderResponse {
                CircularProgressView()
            }
        }
    }

    private func completeOrder() {
        Task {
            do {
                try await paypalWebViewModel.completeOrder(
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
