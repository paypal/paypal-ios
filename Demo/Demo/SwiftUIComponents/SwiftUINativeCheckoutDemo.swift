import Foundation
import SwiftUI
import PayPalUI

struct SwiftUINativeCheckoutDemo: View {

    @StateObject var viewModel = PayPalViewModel()

    @State var isCheckoutViewActive = false

    @State var accessToken = ""

    @State var checkoutTypeSelection = 0


    var body: some View {
        switch viewModel.state {
        case .initial:
            getAccessTokenView
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
                    //Form {
                        Picker("Select type of Checkout: ", selection: $checkoutTypeSelection) {
                            Text("Order Id Checkout").tag(0)
                            Text("Order Checkout").tag(1)
                            Text("Billing Agreement Checkout").tag(2)
                            Text("Vault Checkout").tag(3)
                        }
                    //}
                    Button("Start Checkout") {
                        startNativeCheckoutWithOrderID()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                }
            }
        }.navigationTitle("Native Checkout")
    }

    var getAccessTokenView: some View {
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

    func startNativeCheckoutWithOrderID() {
        Task {
            //try await baseViewModel.checkoutWithNativeClient()
        }
    }
}

@available(iOS 13.0.0, *)
struct SiftUINativeCheckoutDemo_Preview: PreviewProvider {

    static var previews: some View {
        SwiftUINativeCheckoutDemo()
    }
}
