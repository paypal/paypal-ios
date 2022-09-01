import Foundation
import SwiftUI
import PayPalUI

struct SwiftUINativeCheckoutDemo: View {

    enum CheckoutType: String, CaseIterable, Identifiable {
        case order = "Order"
        case orderId = "Order ID"
        case billingAgreement = "Billing Agreement"
        case vault = "Vault"

        var id: CheckoutType { self }
    }

    @StateObject var viewModel = PayPalViewModel()

    @State var checkoutTypeSelection = CheckoutType.order


    var body: some View {
        switch viewModel.state {
        case .initial:
            getAccessTokenView()
        case .loading(let content):
            loadingView(content)
        case let .payPalReady(title, content):
            checkoutView(title, content)
        case .error(let message):
            errorView(message)
        }
    }

    func checkoutView(_ title: String, _ content: String) -> some View {
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    Picker("Checkout ", selection: $checkoutTypeSelection) {
                        ForEach(CheckoutType.allCases, content: { type in
                            Text(type.rawValue)
                        })
                    }
                    Text(title)
                    Text(content)
                    Button("Start Checkout") {
                        startNativeCheckout()
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

    func getAccessTokenView() -> some View {
        NavigationView {
            VStack(spacing: 16) {
                Button("Get Access Token") {
                    viewModel.getAccessToken()
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
        switch checkoutTypeSelection {
        case .order:
            viewModel.checkoutWithOrder()
        case .orderId:
            viewModel.checkoutWithOrderId()
        case .billingAgreement:
            viewModel.checkoutWithBillingAgreement()
        case .vault:
            viewModel.checkoutWithVault()
        }
    }
}

@available(iOS 13.0.0, *)
struct SiftUINativeCheckoutDemo_Preview: PreviewProvider {

    static var previews: some View {
        SwiftUINativeCheckoutDemo()
    }
}
