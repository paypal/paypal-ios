import SwiftUI
import PayPalPayments

struct PayPalVaultViewV2: View {
    
    @Environment(PayPalVaultViewModelV2.self)
    var viewModel
    
    var isCreateSetupTokenLoading: Bool {
        viewModel.createSetupTokenState.isLoading
    }
    
    var isUpdateSetupTokenLoading: Bool {
        viewModel.updateSetupTokenState.isLoading
    }

    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateCardSetupTokenForm(isLoading: isCreateSetupTokenLoading) { request in
                        viewModel.createSetupToken(using: request)
                    }
                    if let createSetupTokenResponse = viewModel.createSetupTokenState.value {
                        CreateSetupTokenResponseView(response: createSetupTokenResponse)
                        UpdatePayPalSetupTokenForm(isLoading: isUpdateSetupTokenLoading) { request in
                            viewModel.updateSetupToken(using: request)
                        }
                    }
                    if let updateSetupTokenResponse = viewModel.updateSetupTokenState.value {
                        PayPalVaultResultView(result: updateSetupTokenResponse)
                    }
                }
            }
        }
        .onOpenURL { url in
            viewModel.handleUniveralLink(url)
        }
    }
}

struct UpdatePayPalSetupTokenForm: View {
    
    let isLoading: Bool
    let onSubmit: (_ request: DemoUpdatePayPalSetupTokenRequest) -> Void
    
    let userActions: [PayPalUserAction] = [.payNow, .continue]
    @State var request = DemoUpdatePayPalSetupTokenRequest()

    var body: some View {
        FormGroup {
            Text("Vault PayPal")
                .font(.system(size: 20))
            Text("User Action")
                .font(.subheadline)
                .foregroundColor(.primary)
            Picker("User Action", selection: $request.userAction) {
                ForEach(userActions, id: \.self) {
                    Text($0.title).tag($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            UserIdentityView(
                selectedUserIdentity: $request.userIdentity,
                email: $request.email,
                phone: $request.phone,
                ssid: $request.ssid
            )
            ButtonWithProgress(label: "Update Setup Token", isLoading: isLoading) {
                onSubmit(request)
            }
        }
    }
}

struct PayPalVaultResultView: View {
    
    let result: PayPalVaultResult
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Success")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(result.tokenID)")
            LeadingText("Status", weight: .bold)
            LeadingText("APPROVED")
            LeadingText("Approval Session ID", weight: .bold)
            LeadingText("\(result.approvalSessionID)")
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
