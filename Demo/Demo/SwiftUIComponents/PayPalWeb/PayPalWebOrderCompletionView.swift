import SwiftUI

struct PayPalWebOrderCompletionView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack {
                    PayPalWebCompleteTransactionView(payPalWebViewModel: payPalWebViewModel)
                    Text("")
                        .id("bottomView")
                    Spacer()
                        .onChange(of: payPalWebViewModel.state) { _ in
                            withAnimation {
                                scrollView.scrollTo("bottomView")
                            }
                        }
                }
            }
        }
    }
}
