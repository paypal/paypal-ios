import SwiftUI

struct CreateOrderForm: View {

    let isLoading: Bool
    let shouldOfferVaultWithPurchase: Bool
    let onSubmit: (_ request: DemoCreateOrderRequest) -> Void

    @State var request = DemoCreateOrderRequest()
    
    init(
        isLoading: Bool,
        shouldOfferVaultWithPurchase: Bool = true,
        onSubmit: @escaping (_ request: DemoCreateOrderRequest) -> Void = { _ in }
    ) {
        self.isLoading = isLoading
        self.shouldOfferVaultWithPurchase = shouldOfferVaultWithPurchase
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        FormGroup {
            StepHeader(text: "Create Order")
            SegmentedEnumPicker(label: "Intent", selection: $request.intent)
            if shouldOfferVaultWithPurchase {
                Toggle("Should Vault with Purchase", isOn: $request.shouldVault)
                FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $request.vaultCustomerID)
            }
            FloatingLabelTextField(placeholder: "Amount", text: $request.amount, keyboardType: .decimalPad)
            ButtonWithProgress(label: "Create an Order", isLoading: isLoading) {
                onSubmit(request)
            }
        }
    }
}
