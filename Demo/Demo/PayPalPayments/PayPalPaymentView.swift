import SwiftUI
import PayPalPayments

struct PayPalPaymentView: View {
    
    @Environment(PayPalPaymentViewModel.self)
    var viewModel
    
    var isOrderCreationLoading: Bool {
        viewModel.createOrderState.isLoading
    }
    
    var isApproveOrderLoading: Bool {
        viewModel.approveOrderState.isLoading
    }
    
    var isCompleteOrderLoading: Bool {
        viewModel.completeOrderState.isLoading
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateOrderForm(isLoading: isOrderCreationLoading) { request in
                        viewModel.createOrder(using: request)
                    }
                    if let order = viewModel.createOrderState.value {
                        OrderView(order: order)
                        ApproveOrderWithPayPalForm(isLoading: isApproveOrderLoading) { request in
                            viewModel.approveOrder(using: request)
                        }
                    }
                    
                    if let approveOrderResult = viewModel.approveOrderState.value {
                        PayPalCheckoutResultView(result: approveOrderResult)
                        let intent = viewModel.orderIntent
                        CompleteOrderForm(intent: intent, isLoading: isCompleteOrderLoading) {
                            viewModel.completeOrder()
                        }
                    }
                    
                    if let completeOrderResult = viewModel.completeOrderState.value {
                        OrderView(order: completeOrderResult)
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
    
    struct ApproveOrderWithPayPalForm: View {
        
        let isLoading: Bool
        let onSubmit: (_ request: DemoApproveOrderWithPayPalRequest) -> Void

        @State var request = DemoApproveOrderWithPayPalRequest()

        var body: some View {
            FormGroup {
                Text("User Action")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Picker("User Action", selection: $request.userAction) {
                    ForEach(PayPalUserAction.checkoutActions, id: \.self) {
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
                FloatingLabelTextField(
                    placeholder: "Amount",
                    text: $request.amount,
                    keyboardType: .decimalPad
                )
                ButtonWithProgress(label: "Checkout with PayPal", isLoading: isLoading) {
                    onSubmit(request)
                }
            }
        }
    }
    
    struct PayPalCheckoutResultView: View {
        
        let result: PayPalCheckoutResult
        
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                Text("PayPal Checkout Result")
                    .font(.headline)
                LeadingText("Order ID", weight: .bold)
                    .font(.system(size: 20))
                LeadingText(result.orderID)
                LeadingText("Payer ID", weight: .bold)
                LeadingText(result.payerID)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
                    .padding(5)
            )
        }
    }
}
