import SwiftUI

struct PayPalWebTransactionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
//                    PayPalWebStatusView(status: .approved, payPalWebViewModel: payPalWebViewModel)
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

                    if payPalWebViewModel.transactionResult != nil && payPalWebViewModel.state == .success {
                        PayPalWebResultView(payPalWebViewModel: payPalWebViewModel)
                            .id("bottomView")
                    } else if case .error = payPalWebViewModel.state {
                        PayPalWebResultView(payPalWebViewModel: payPalWebViewModel)
                    }
                }
                .onChange(of: payPalWebViewModel.transactionResult) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
                Spacer()
            }
        }
    }
}
