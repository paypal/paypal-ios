import Foundation
import SwiftUI
import PayPalUI

struct SwiftUINativeCheckoutDemo: View {

    @StateObject var baseViewModel = BaseViewModel()

    var body: some View {
        ZStack {
            FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
            VStack(spacing: 16) {
                Button("native chekcout") {
                    Task {
                        guard let orderId = baseViewModel.orderID else {
                            return
                        }
                        _ = try await baseViewModel.checkoutWithNativeClient(orderId: orderId)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(10)
                .padding(.horizontal, 16)
            }
        }
    }
}

@available(iOS 13.0.0, *)
struct SiftUINativeCheckoutDemo_Preview: PreviewProvider {

    static var previews: some View {
        SwiftUINativeCheckoutDemo(baseViewModel: BaseViewModel())
    }
}
