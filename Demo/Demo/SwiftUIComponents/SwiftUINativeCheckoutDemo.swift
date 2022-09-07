import Foundation
import SwiftUI
import PayPalUI

struct SwiftUINativeCheckoutDemo: View {

    enum CheckoutType: String, CaseIterable, Identifiable {
        case order = "Order"
        case orderID = "Order ID"
        case billingAgreement = "Billing Agreement"
        case baWithoutPurchase = "Billing Agreement without purchase"
        case vault = "Vault"

        var id: CheckoutType { self }
    }

    @StateObject var viewModel = PayPalViewModel()

    @State var checkoutTypeSelection = CheckoutType.order

    init() {
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
        UITableView.appearance().tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
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
        NavigationView {
            ZStack {
                VStack(spacing: 16) {
                    VStack {
                        Form {
                            Picker("Checkout ", selection: $checkoutTypeSelection) {
                                ForEach(CheckoutType.allCases) {type in
                                    Text(type.rawValue)
                                }
                            }
                        }.navigationBarTitle("", displayMode: .inline)
                    }.frame(height: 75)
                    VStack {
                        Text(title)
                            .font(.system(size: 24))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .bottom], 16)
                        Text(content)
                            .font(.system(size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.leading, .bottom], 16)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    VStack {
                        Button(isFlowComplete ? "Try Again" : "Start Checkout" ) {
                            if isFlowComplete {
                                viewModel.retry()
                            } else {
                                startNativeCheckout()
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }.frame(maxHeight: .infinity)
            }
        }.navigationBarHidden(true)
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
        case .orderID:
            viewModel.checkoutWithOrderID()
        case .billingAgreement:
            viewModel.checkoutWithBillingAgreement()
        case .baWithoutPurchase:
            viewModel.checkoutBAWithoutPurchase()
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
