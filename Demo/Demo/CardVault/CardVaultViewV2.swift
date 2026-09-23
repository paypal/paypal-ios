import SwiftUI

struct CardVaultViewV2: View {
    
    @Environment(CardVaultViewModelV2.self)
    var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateSetupTokenForm(isLoading: viewModel.isLoadingSetupToken) { request in
                        viewModel.createSetupToken(with: request)
                    }
                }
            }
        }
    }
}

struct CreateSetupTokenForm: View {
    var isLoading: Bool
    @State var request = DemoCreateSetupTokenRequest()
    let action: (_ request: DemoCreateSetupTokenRequest) -> Void
    var body: some View {
        FormGroup {
            StepHeader(text: "Create Setup Token")
            FloatingLabelTextField(
                placeholder: "Vault Customer ID (Optional)", text: $request.customerID)
            let isLoading = false
            ButtonWithProgress(label: "Create Setup Token", isLoading: isLoading) {
                action(request)
            }
        }
    }
}
