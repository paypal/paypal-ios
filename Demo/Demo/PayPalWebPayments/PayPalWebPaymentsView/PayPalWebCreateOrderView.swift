import SwiftUI
import PayPalWebPayments

extension PayPalUserAction {

    var title: String {
        switch self {
        case .continue:
            return "CONTINUE"
        case .payNow:
            return "PAY NOW"
        case .setupNow:
            return "SETUP NOW"
        }
    }
}

struct PayPalWebCreateOrderView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    @State private var selectedIntent: Intent = .authorize
    @State private var selectedUserAction: PayPalUserAction = .payNow
    @State private var selectedUserIdentity: UserIdentitySelection = .none
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var ssid: String = ""
    @State var shouldVaultSelected = false

    var body: some View {
        ScrollView {
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Intent")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Picker("Intent", selection: $selectedIntent) {
                        ForEach(Intent.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("User Action")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Picker("User Action", selection: $selectedUserAction) {
                        ForEach([PayPalUserAction.payNow, PayPalUserAction.continue], id: \.self) {
                            Text($0.title).tag($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                UserIdentityView(
                    selectedUserIdentity: $selectedUserIdentity,
                    email: $email,
                    phone: $phone,
                    ssid: $ssid
                )
                HStack {
                    Toggle("Should Vault with Purchase", isOn: $shouldVaultSelected)
                    Spacer()
                }
                ZStack {
                    Button("Checkout") {
                        Task {
                            do {
                                payPalWebViewModel.intent = selectedIntent
                                try await payPalWebViewModel.checkout(
                                    shouldVault: shouldVaultSelected,
                                    userAction: selectedUserAction,
                                    userIdentity: UserIdentityFactory.makeUserIdentity(
                                        selection: selectedUserIdentity,
                                        email: email,
                                        phone: phone,
                                        ssid: ssid
                                    )
                                )
                            } catch {
                                print("Error in checkout. \(error.localizedDescription)")
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
}
