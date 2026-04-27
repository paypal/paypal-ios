import SwiftUI

struct CardPaymentView: View {

    @StateObject var cardPaymentViewModel = CardPaymentViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Step1_CreateOrder(onCreateOrderPress: { demoOrder in
                    Task {
                        let vaultCustomerID = demoOrder.vaultCustomerID
                        try await cardPaymentViewModel.createOrder(
                            amount: "10.00",
                            selectedMerchantIntegration: DemoSettings.merchantIntegration,
                            intent: demoOrder.intent.rawValue,
                            shouldVault: demoOrder.shouldVault,
                            customerID: vaultCustomerID.isEmpty ? nil : vaultCustomerID
                        )
                        // TODO: update UI
                    }
                }, isLoading: false)
                if let order = cardPaymentViewModel.state.createOrder {
                    OrderCreateCardResultView(cardPaymentViewModel: cardPaymentViewModel)
                    NavigationLink {
                        CardOrderApproveView(orderID: order.id, cardPaymentViewModel: cardPaymentViewModel)
                    } label: {
                        Text("Approve Order with Card")
                    }
                    .buttonStyle(RoundedBlueButtonStyle())
                    .padding()
                }
            }
        }
    }
}

struct Step1_CreateOrder: View {
    
    let onCreateOrderPress: (DemoOrder) -> Void
    let isLoading: Bool
    
    @State var intent: Intent = .capture
    @State var shouldVault = false
    @State private var vaultCustomerID: String = ""

    var body: some View {
        FormGroup {
            StepHeader(text: "Create Order")
            SegmentedEnumPicker(selection: $intent)
            Toggle("Should Vault with Purchase", isOn: $shouldVault)
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $vaultCustomerID)
            
            ButtonWithProgress(label: "Create an Order", state: isLoading ? .loading : .idle) {
                let demoOrder = DemoOrder(
                    intent: intent,
                    shouldVault: shouldVault,
                    vaultCustomerID: vaultCustomerID
                )
                onCreateOrderPress(demoOrder)
            }
        }
    }
}


#Preview {
    Step1_CreateOrder(onCreateOrderPress: { _ in }, isLoading: false)
}
