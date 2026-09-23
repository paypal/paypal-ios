import SwiftUI

struct CardVaultViewV2: View {
    
    @Environment(CardVaultViewModelV2.self)
    var viewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateSetupTokenForm(request: $viewModel.createSetupTokenRequest)
                }
            }
        }
    }
}

struct CreateSetupTokenForm: View {
    @Binding var request: DemoCreateSetupTokenRequest
    var body: some View {
        FormGroup {
            StepHeader(text: "Create Setup Token")
            FloatingLabelTextField(
                placeholder: "Vault Customer ID (Optional)", text: $request.customerID)
        }
    }
}
