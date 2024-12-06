import SwiftUI

struct PayPalWebTransactionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack {
            ZStack {
                Button("\(payPalWebViewModel.intent.rawValue.capitalized) Order") {
                    Task {
                        do {
                            try await payPalWebViewModel.completeTransaction()
                        } catch {
                            print("Error capturing order: \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()

                if payPalWebViewModel.state.capturedOrderResponse == .loading ||
                    payPalWebViewModel.state.authorizedOrderResponse == .loading {
                    CircularProgressView()
                }
            }
        }
    }
}
