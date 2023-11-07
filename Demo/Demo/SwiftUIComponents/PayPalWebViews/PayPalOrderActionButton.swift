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
        if intent == .capture {
            Task {
                do {
                    try await paypalWebViewModel.captureOrder(
                        orderID: orderID,
                        selectedMerchantIntegration: selectedMerchantIntegration
                    )
                    print("Order Captured. ID: \(paypalWebViewModel.state.capturedOrder?.id ?? "")")
                } catch {
                    print("Error capturing order: \(error.localizedDescription)")
                }
            }
        } else {
            Task {
                do {
                    try await paypalWebViewModel.authorizeOrder(
                        orderID: orderID,
                        selectedMerchantIntegration: selectedMerchantIntegration
                    )
                    print("Order Authorized. ID: \(paypalWebViewModel.state.authorizedOrder?.id ?? "")")
                } catch {
                    print("Error authorizing order: \(error.localizedDescription)")
                }
            }
        }
    }
}
