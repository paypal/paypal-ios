import SwiftUI

struct PayPalWebOrderActionButton: View {
    let intent: Intent
    let orderID: String
    let selectedMerchantIntegration: MerchantIntegration

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        ZStack {
            Button("\(intent.rawValue.capitalized) Order") {
                completeOrder()
            }
            .buttonStyle(RoundedBlueButtonStyle())
            .padding()
            if intent == .authorize && payPalWebViewModel.state.authorizedOrderResponse == .loading ||
                intent == .capture && payPalWebViewModel.state.capturedOrderResponse == .loading {
                CircularProgressView()
            }
        }
    }

    private func completeOrder() {
        Task {
            do {
                if intent == .capture {
                    try await payPalWebViewModel.captureOrder(
                        orderID: orderID,
                        selectedMerchantIntegration: selectedMerchantIntegration
                    )
                    print("Order Captured. ID: \(payPalWebViewModel.state.capturedOrder?.id ?? "")")
                } else if intent == .authorize {
                    try await payPalWebViewModel.authorizeOrder(
                        orderID: orderID,
                        selectedMerchantIntegration: selectedMerchantIntegration
                    )
                    print("Order Authorized. ID: \(payPalWebViewModel.state.authorizedOrder?.id ?? "")")
                }
            } catch {
                print("Error completing \(intent.rawValue.capitalized) order: \(error.localizedDescription)")
            }
        }
    }
}
