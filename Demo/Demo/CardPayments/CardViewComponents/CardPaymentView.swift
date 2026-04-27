import SwiftUI

struct CardPaymentView: View {

    @StateObject var cardPaymentViewModel = CardPaymentViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CreateOrderCardPaymentView(
                    cardPaymentViewModel: cardPaymentViewModel,
                    selectedMerchantIntegration: DemoSettings.merchantIntegration
                )
                
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
    
    let onCreateOrderPress: () -> Void
    let isLoading: Bool
    
    @State var intent: Intent = .capture
    @State var shouldVaultSelected = false
    @State private var vaultCustomerID: String = ""

    var body: some View {
        StepHeader(text: "Create Order")
        SegmentedEnumPicker(selection: $intent)
        Toggle("Should Vault with Purchase", isOn: $shouldVaultSelected)
        FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $vaultCustomerID)
        ButtonWithProgress(
            label: "Create an Order",
            state: isLoading ? .loading : .idle,
            action: onCreateOrderPress
        )
    }
}


#Preview {
    Step1_CreateOrder(onCreateOrderPress: {}, isLoading: false)
}
