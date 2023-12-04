import SwiftUI

struct PayPalWebTransactionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    PayPalWebStatusView(payPalWebViewModel: payPalWebViewModel)
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

                    if payPalWebViewModel.state == .transactionSuccess {
                        PayPalWebResultView(payPalWebViewModel: payPalWebViewModel)
                            .id("bottomView")
                    }
                }
                .onChange(of: payPalWebViewModel.order) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomView")
                    }
                }
                Spacer()
            }
        }
    }
}
