import SwiftUI

struct CreateSetupTokenView: View {

    let selectedMerchantIntegration: MerchantIntegration

    @State private var vaultCustomerID: String = ""
    @State private var sca: String = "SCA_WHEN_REQUIRED"
    @State var paymentSourceType: PaymentSourceType

    @ObservedObject var vaultViewModel: VaultViewModel

    public init(selectedMerchantIntegration: MerchantIntegration, vaultViewModel: VaultViewModel, paymentSourceType: PaymentSourceType) {
        self.selectedMerchantIntegration = selectedMerchantIntegration
        self.vaultViewModel = vaultViewModel
        self.paymentSourceType = paymentSourceType
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
            if case .card = paymentSourceType {
                Picker("SCA", selection: $sca) {
                    Text("SCA_WHEN_REQUIRED").tag("SCA_WHEN_REQUIRED")
                    Text("SCA_ALWAYS").tag("SCA_ALWAYS")
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(height: 50)
            }

            ZStack {
                Button("Create Setup Token") {
                    Task {
                        do {
                            try await vaultViewModel.getSetupToken(
                                customerID: vaultCustomerID.isEmpty ? nil : vaultCustomerID,
                                selectedMerchantIntegration: selectedMerchantIntegration,
                                paymentSourceType: paymentSourceType
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
        .onChange(of: sca) { _ in
            paymentSourceType = PaymentSourceType.card(verification: sca)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
