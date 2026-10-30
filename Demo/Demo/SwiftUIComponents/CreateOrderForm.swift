import SwiftUI

struct CreateOrderForm: View {

    let isLoading: Bool
    let onSubmit: (_ request: DemoCreateOrderRequest) -> Void

    @State var request = DemoCreateOrderRequest()

    var body: some View {
        FormGroup {
            StepHeader(text: "Create Order")
            SegmentedEnumPicker(label: "Intent", selection: $request.intent)
            Toggle("Should Vault with Purchase", isOn: $request.shouldVault)
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $request.vaultCustomerID)
            FloatingLabelTextField(placeholder: "Amount", text: $request.amount, keyboardType: .decimalPad)
            ButtonWithProgress(label: "Create an Order", isLoading: isLoading) {
                onSubmit(request)
            }
        }
    }
}
