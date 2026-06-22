import SwiftUI

// TODO: Replace with PayPalUserAction from SDK when feature/shopper-session-id merges
enum UserActionSelection: String, CaseIterable {
    case `continue` = "CONTINUE"
    case payNow = "PAY NOW"
}

struct PayPalWebCreateOrderView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    @State private var selectedIntent: Intent = .authorize
    @State private var selectedUserAction: UserActionSelection = .payNow
    @State var shouldVaultSelected = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Checkout")
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
            Picker("User Action", selection: $selectedUserAction) {
                Text("PAY NOW").tag(UserActionSelection.payNow)
                Text("CONTINUE").tag(UserActionSelection.continue)
            }
            .pickerStyle(SegmentedPickerStyle())
            HStack {
                Toggle("Should Vault with Purchase", isOn: $shouldVaultSelected)
                Spacer()
            }
            ZStack {
                Button("Checkout") {
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
        .onAppear {
            UISegmentedControl.appearance().selectedSegmentTintColor = .systemBlue
            UISegmentedControl.appearance().setTitleTextAttributes(
                [.foregroundColor: UIColor.white], for: .selected
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
