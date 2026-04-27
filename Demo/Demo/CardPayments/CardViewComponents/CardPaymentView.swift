import SwiftUI

struct CardPaymentView: View {

    @StateObject var cardPaymentViewModel = CardPaymentViewModel()
    @State var order: Order?
    @State var isCreatingOrder = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CreateOrderForm(onCreateOrderPress: { request in
                    isCreatingOrder = true
                    Task {
                        do {
                            order = try await cardPaymentViewModel.createOrder(using: request)
                            isCreatingOrder = false
                        } catch {
                            print("❌ failed to fetch orderID: \(error)")
                        }
                    }
                }, isLoading: isCreatingOrder)
                if let order {
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

struct CreateOrderForm: View {
    
    let onCreateOrderPress: (DemoOrderRequest) -> Void
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
                let demoOrder = DemoOrderRequest(
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
    CreateOrderForm(onCreateOrderPress: { _ in }, isLoading: false)
}
