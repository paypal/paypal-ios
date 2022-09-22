import Foundation
import SwiftUI
import PayPalUI

struct SwiftUINativeCheckoutDemo: View {

    @StateObject var viewModel = PayPalViewModel()

    @State var shippingTypeSelection = ShippingType.noShipping

    enum ShippingType: String, CaseIterable, Identifiable {
        case noShipping = "No shipping"
        case providedAddress = "Set provided address"
        case getFromFile = "Get from file"

        var id: ShippingType { self }
    }

    var body: some View {
        switch viewModel.state {
        case .initial:
            getAccessTokenView()
        case .loading(let content):
            loadingView(content)
        case let .mainContent(title, content, isFlowComplete):
            checkoutView(title, content, isFlowComplete)
        }
    }

    func checkoutView(_ title: String, _ content: String, _ isFlowComplete: Bool) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Shipping type selection:")
                Spacer()
                Picker("", selection: $shippingTypeSelection) {
                    ForEach(ShippingType.allCases) { type in
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

struct SwiftUINativeCheckoutDemo_Preview: PreviewProvider {

    static var previews: some View {
        SwiftUINativeCheckoutDemo()
    }
}
