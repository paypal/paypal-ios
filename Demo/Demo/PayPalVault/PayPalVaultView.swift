import SwiftUI
import PayPalPayments

struct PayPalVaultView: View {
    
    @Environment(PayPalVaultViewModel.self)
    var viewModel
    
    var createSetupTokenState: AsyncState<CreateSetupTokenResponse> { viewModel.createSetupTokenState }
    var updateSetupTokenState: AsyncState<PayPalVaultResult> { viewModel.updateSetupTokenState }
    var createPaymentTokenState: AsyncState<PaymentTokenResponse> { viewModel.createPaymentTokenState }

    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                VStack(spacing: 16) {
                    CreatePayPalSetupTokenForm(isLoading: createSetupTokenState.isLoading) { request in
                        viewModel.createSetupToken(using: request)
                    }
                    UnwrapValueOrError(createSetupTokenState) { createSetupTokenResponse in
                        CreateSetupTokenResponseView(response: createSetupTokenResponse)
                        UpdatePayPalSetupTokenForm(isLoading: updateSetupTokenState.isLoading) { request in
                            viewModel.updateSetupToken(using: request)
                        }
                    }
                    UnwrapValueOrError(updateSetupTokenState) { updateSetupTokenResponse in
                        PayPalVaultResultView(result: updateSetupTokenResponse)
                        CreatePaymentTokenForm(isLoading: createPaymentTokenState.isLoading) {
                            viewModel.createPaymentToken()
                        }
                    }
                    UnwrapValueOrError(createPaymentTokenState) { paymentTokenResponse in
                        PaymentTokenResponseView(response: paymentTokenResponse)
                    }
                    ScrollAnchor(id: "bottomAnchor")
                }
                .onChange(of: viewModel.stateHash) {
                    withAnimation {
                        proxy.scrollTo("bottomAnchor")
                    }
                }
            }
        }
        .onOpenURL { url in
            viewModel.handleUniversalLink(url)
        }
    }
}

struct UpdatePayPalSetupTokenForm: View {
    
    let isLoading: Bool
    let onSubmit: (_ request: DemoUpdatePayPalSetupTokenRequest) -> Void
    
    let userActions: [PayPalUserAction] = [.setupNow, .continue]
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
