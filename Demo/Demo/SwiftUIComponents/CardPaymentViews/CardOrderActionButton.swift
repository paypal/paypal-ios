import SwiftUI

struct CardOrderActionButton: View {

    let intent: String
    let orderID: String
    let selectedMerchantIntegration: MerchantIntegration

    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    var body: some View {
        ZStack {
            Button("\(intent)") {
                completeOrder()
            }
            .buttonStyle(RoundedBlueButtonStyle())
            .padding()
            if case .loading = cardPaymentViewModel.state.authorizedOrderResponse {
                CircularProgressView()
            } else if case .loading = cardPaymentViewModel.state.capturedOrderResponse {
                CircularProgressView()
            }
        }
    }

    private func completeOrder() {
        if intent == "CAPTURE" {
            Task {
                do {
                    try await cardPaymentViewModel.captureOrder(
                        orderID: orderID,
                        selectedMerchantIntegration: selectedMerchantIntegration
                    )
                    print("Order Captured. ID: \(cardPaymentViewModel.state.capturedOrder?.id ?? "")")
                } catch {
                    print("Error capturing order: \(error.localizedDescription)")
                }
            }
        } else {
            Task {
                do {
                    try await cardPaymentViewModel.authorizeOrder(
                        orderID: orderID,
                        selectedMerchantIntegration: selectedMerchantIntegration
                    )
                    print("Order Authorized. ID: \(cardPaymentViewModel.state.authorizedOrder?.id ?? "")")
                } catch {
                    print("Error authorizing order: \(error.localizedDescription)")
                }
            }
        }
    }
}
