import SwiftUI

struct OrderActionButton: View {

    let intent: String
    let order: Order
    let selectedMerchantIntegration: MerchantIntegration

    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    var body: some View {
        ZStack {
            Button("\(intent)") {
                if intent == "CAPTURE" {
                    Task {
                        do {
                            try await cardVaultViewModel.captureOrder(orderID: order.id, selectedMerchantIntegration: selectedMerchantIntegration)
                            print("Order Captured. ID: \(cardVaultViewModel.state.capturedOrder?.id ?? "")")
                        } catch {
                            print("Error capturing order: \(error.localizedDescription)")
                        }
                    }
                } else {
                    Task {
                        do {
                            try await cardVaultViewModel.authorizeOrder(orderID: order.id, selectedMerchantIntegration: selectedMerchantIntegration)
                            print("Order Authorized. ID: \(cardVaultViewModel.state.authorizedOrder?.id ?? "")")
                        } catch {
                            print("Error authorizing order: \(error.localizedDescription)")
                        }
                    }
                }
            }
            .buttonStyle(RoundedBlueButtonStyle())
            .padding()
            if case .loading = cardVaultViewModel.state.authorizedOrderResponse {
                CircularProgressView()
            } else if case .loading = cardVaultViewModel.state.capturedOrderResponse {
                CircularProgressView()
            }
        }
    }
}
