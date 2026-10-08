import SwiftUI
import CardPayments

struct PayPalPaymentView: View {
    
    @Environment(PayPalPaymentViewModel.self)
    var viewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Text("Hello")
                }
            }
        }
    }
}
