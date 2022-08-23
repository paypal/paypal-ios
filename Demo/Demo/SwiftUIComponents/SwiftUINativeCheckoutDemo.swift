import Foundation
import SwiftUI
import PayPalUI

struct SwiftUINativeCheckoutDemo: View {

    @StateObject var baseViewModel = BaseViewModel()

    @State var isCheckoutViewActive = false

    @State var accessToken = ""

    @State var checkoutTypeSelection = 0

    var checkoutView: some View {
        NavigationView {
            ZStack {
                FeatureBaseViewControllerRepresentable(baseViewModel: baseViewModel)
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
                NavigationLink(destination: checkoutView, isActive: $isCheckoutViewActive) {
                    Button("Get Access Token") {
                        getAccessToken()
                        isCheckoutViewActive = true
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


    var body: some View {
        getAccessTokenView
    }


    func getAccessToken() {
        Task {
            guard let token = await baseViewModel.getAccessToken() else {
                baseViewModel.updateTitle("error in getting access token")
                return
            }
            accessToken = token
        }
    }

    func startNativeCheckoutWithOrderID() {
        Task {
            try await baseViewModel.checkoutWithNativeClient()
        }
    }
}

@available(iOS 13.0.0, *)
struct SiftUINativeCheckoutDemo_Preview: PreviewProvider {

    static var previews: some View {
        SwiftUINativeCheckoutDemo(baseViewModel: BaseViewModel())
    }
}
