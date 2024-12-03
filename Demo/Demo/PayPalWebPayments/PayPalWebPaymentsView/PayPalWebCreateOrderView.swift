import SwiftUI

struct PayPalWebCreateOrderView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    @State private var selectedIntent: Intent = .authorize
    @State var shouldVaultSelected = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create an Order")
                    .font(.system(size: 20))
                Spacer()
                Button("Reset") {
                    payPalWebViewModel.resetState()
                }
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
                            payPalWebViewModel.intent = selectedIntent
                            try await payPalWebViewModel.createOrder(shouldVault: shouldVaultSelected)
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = payPalWebViewModel.state.createdOrderResponse {
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
