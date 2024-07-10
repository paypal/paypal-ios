import Foundation
import SwiftUI
import PaymentButtons

@available(*, deprecated, message: "PayPalNativePayments Module is deprecated, use PayPalWebPayments Module instead")
struct SwiftUINativeCheckoutDemo: View {

    @StateObject var viewModel = PayPalViewModel()

    @State var shippingTypeSelection = ShippingPreference.noShipping

    var body: some View {
        switch viewModel.state {
        case .initial:
            getClientIDView()
        case .loading(let content):
            loadingView(content)
        case let .mainContent(title, content, isFlowComplete):
            checkoutView(title, content, isFlowComplete)
        case .error(let message):
            errorView("Error \(message)")
        }
    }

    func checkoutView(_ title: String, _ content: String, _ isFlowComplete: Bool) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Shipping type selection:")
                Spacer()
                Picker("", selection: $shippingTypeSelection) {
                    ForEach(ShippingPreference.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
            }
            .padding(16)
            Divider()
            VStack {
                Text(title)
                    .font(.system(size: 24))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .bottom], 16)
                Text(content)
                    .font(.system(size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing, .bottom], 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            VStack {
                Button(isFlowComplete ? "Try Again" : "Start Checkout" ) {
                    isFlowComplete ? viewModel.retry() : startNativeCheckout()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .cornerRadius(10)
                .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(maxHeight: .infinity)
        .padding(.top, 32)
    }

    func getClientIDView() -> some View {
        NavigationView {
            VStack(spacing: 16) {
                Button("Get ClientID") {
                    viewModel.getClientID()
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

    func loadingView(_ content: String) -> some View {
        VStack(spacing: 16) {
            ProgressView(content)
                .progressViewStyle(CircularProgressViewStyle())
        }
    }

    func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
        }
    }

    func startNativeCheckout() {
        switch shippingTypeSelection {
        case .noShipping:
            viewModel.checkoutWithNoShipping()
        case .providedAddress:
            viewModel.checkoutWithProvidedAddress()
        case .getFromFile:
            viewModel.checkoutWithGetFromFile()
        }
    }
}

@available(*, deprecated, message: "PayPalNativePayments Module is deprecated, use PayPalWebPayments Module instead")
struct SwiftUINativeCheckoutDemo_Preview: PreviewProvider {

    static var previews: some View {
        SwiftUINativeCheckoutDemo()
    }
}
