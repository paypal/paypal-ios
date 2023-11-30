import SwiftUI

struct CreateOrderPayPalWebView: View {

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel

    @State private var selectedIntent: Intent = .authorize
    @State var shouldVaultSelected = false

    let selectedMerchantIntegration: MerchantIntegration

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create an Order")
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            Picker("Intent", selection: $selectedIntent) {
                Text("AUTHORIZE").tag(Intent.authorize)
                Text("CAPTURE").tag(Intent.capture)
            }
            .pickerStyle(SegmentedPickerStyle())
            HStack {
                Toggle("Should Vault with Purchase", isOn: $shouldVaultSelected)
                Spacer()
            }
            ZStack {
                Button("Create an Order") {
                    Task {
                        do {
                            paypalWebViewModel.state.intent = selectedIntent
                            try await paypalWebViewModel.createOrder(
                                amount: "10.00",
                                selectedMerchantIntegration: DemoSettings.merchantIntegration,
                                intent: selectedIntent.rawValue,
                                shouldVault: shouldVaultSelected
                            )
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = paypalWebViewModel.state.createdOrderResponse {
                    CircularProgressView()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
