import SwiftUI
import PayPalPayments

struct PayPalPaymentView: View {
    
    @Environment(PayPalPaymentViewModel.self)
    var viewModel
    
    var isOrderCreationLoading: Bool {
        viewModel.createOrderState.isLoading
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
                        ApproveOrderWithPayPalForm(isLoading: false) { request in
                            viewModel.approveOrder(using: request)
                        }
                    }
                }
                .onChange(of: viewModel.stateHash) {
                    withAnimation {
                        proxy.scrollTo("bottomAnchor")
                    }
                }
            }
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
}
