import SwiftUI
import PayPalWebPayments

struct CreateSetupTokenView: View {

    let selectedMerchantIntegration: MerchantIntegration

    @State private var sca: String = "SCA_WHEN_REQUIRED"
    @State var paymentType: PaymentType

    @ObservedObject var vaultViewModel: VaultViewModel

    public init(selectedMerchantIntegration: MerchantIntegration, vaultViewModel: VaultViewModel, paymentType: PaymentType) {
        self.selectedMerchantIntegration = selectedMerchantIntegration
        self.vaultViewModel = vaultViewModel
        self.paymentType = paymentType
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault without Purchase requires creation of setup token:")
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $vaultViewModel.customerID)
            if case .card = paymentType {
                Picker("SCA", selection: $sca) {
                    Text("SCA_WHEN_REQUIRED").tag("SCA_WHEN_REQUIRED")
                    Text("SCA_ALWAYS").tag("SCA_ALWAYS")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(height: 50)
            }

            if paymentType == .paypal {
                VStack(alignment: .leading, spacing: 8) {
                    Text("User Action")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    Picker("User Action", selection: $vaultViewModel.selectedUserAction) {
                        ForEach([PayPalUserAction.setupNow, PayPalUserAction.continue], id: \.self) {
                            Text($0.title).tag($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                UserIdentityView(
                    selectedUserIdentity: $vaultViewModel.selectedUserIdentity,
                    email: $vaultViewModel.userEmail,
                    phone: $vaultViewModel.userPhone,
                    ssid: $vaultViewModel.userSSID
                )
            }
            ZStack {
                Button("Checkout") {
                    Task {
                        do {
                            switch paymentType {
                            case .paypal:
                                guard let paypalVaultViewModel = vaultViewModel as? PayPalVaultViewModel else { return }
                                try await paypalVaultViewModel.vault()
                            case .card:
                                _ = try await vaultViewModel.fetchSetupToken(
                                    customerID: vaultViewModel.customerID.isEmpty ? nil : vaultViewModel.customerID,
                                    selectedMerchantIntegration: selectedMerchantIntegration,
                                    paymentType: paymentType,
                                    sca: sca
                                )
                            }
                        } catch {
                            print("Error in vault flow. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = vaultViewModel.state.setupTokenResponse {
                    CircularProgressView()
                } else if paymentType == .paypal, case .loading = vaultViewModel.state.paypalVaultTokenResponse {
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
