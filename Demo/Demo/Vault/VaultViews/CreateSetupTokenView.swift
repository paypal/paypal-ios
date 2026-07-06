import SwiftUI

struct CreateSetupTokenView: View {

    let selectedMerchantIntegration: MerchantIntegration

    @State private var vaultCustomerID: String = ""
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
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $vaultCustomerID)
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
                        ForEach(UserActionSelection.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
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
                            try await vaultViewModel.getSetupToken(
                                customerID: vaultCustomerID.isEmpty ? nil : vaultCustomerID,
                                selectedMerchantIntegration: selectedMerchantIntegration,
                                paymentType: paymentType,
                                sca: sca
                            )
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = vaultViewModel.state.setupTokenResponse {
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
