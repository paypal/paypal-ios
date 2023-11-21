import SwiftUI

struct PayPalWebTransactionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        VStack {
            PayPalWebStatusView(status: .approved, payPalViewModel: payPalWebViewModel)
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

                if payPalWebViewModel.state == .loading {
                    CircularProgressView()
                }
            }

            if payPalWebViewModel.state == .success {
                PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .completed)
            }
        }
        Spacer()
    }
}
