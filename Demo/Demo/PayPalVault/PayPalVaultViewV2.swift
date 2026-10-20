import SwiftUI
import PayPalPayments

struct PayPalVaultViewV2: View {
    
    @Environment(PayPalVaultViewModelV2.self)
    var viewModel
    
    var isCreateSetupTokenLoading: Bool {
        viewModel.createSetupTokenState.isLoading
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
                        UpdatePayPalSetupTokenForm(isLoading: false) { request in
                            viewModel.updateSetupToken(using: request)
                        }
                    }
                }
            }
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
