import SwiftUI

struct PayPalWebTransactionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack {
            PayPalWebStatusView(status: .approved, intent: payPalWebViewModel.intent, payPalViewModel: payPalWebViewModel)
            ZStack {
                Button("\(payPalWebViewModel.intent.rawValue)") {
                    Task {
                        do {
                            try await payPalWebViewModel.completeOrder()
                        } catch {
                            print("Error capturing order: \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()
                if payPalWebViewModel.state == .loading {
                    CircularProgressView()
                }
            }

            if payPalWebViewModel.state == .success {
                PayPalWebStatusView(status: .completed, intent: payPalWebViewModel.intent, payPalViewModel: payPalWebViewModel)
            }
        }
        Spacer()
    }
}
