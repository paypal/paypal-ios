import SwiftUI

struct PayPalWebTransactionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    PayPalWebStatusView(status: .approved, payPalWebViewModel: payPalWebViewModel)
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

                        if payPalWebViewModel.authorizeCpatureOrderState == .loading {
                            CircularProgressView()
                        }
                    }

                    PayPalWebResultView(payPalWebViewModel: payPalWebViewModel, status: .completed)
                        .id("bottomView")
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
