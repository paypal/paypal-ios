import SwiftUI
import CardPayments

struct CardPaymentView: View {
    
    @Environment(CardPaymentViewModel.self)
    var viewModel
    
    var createOrderState: AsyncState<Order> { viewModel.createOrderState }
    var approveOrderState: AsyncState<CardResult> { viewModel.approveOrderState }
    var completeOrderState: AsyncState<Order> { viewModel.completeOrderState }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateOrderForm(isLoading: createOrderState.isLoading) { request in
                        viewModel.createOrder(using: request)
                    }
                    UnwrapValueOrError(createOrderState) { order in
                        OrderView(order: order)
                        ApproveOrderWithCardForm(isLoading: approveOrderState.isLoading) { request in
                            viewModel.approveOrder(using: request)
                        }
                    }
                    UnwrapValueOrError(approveOrderState) { cardResult in
                        CardResultView(cardResult: cardResult)
                        let intent = viewModel.orderIntent
                        CompleteOrderForm(intent: intent, isLoading: completeOrderState.isLoading) {
                            viewModel.completeOrder()
                        }
                    }
                    UnwrapValueOrError(completeOrderState) { completeOrderResult in
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
    }
}

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
            
            ButtonWithProgress(label: "Create an Order", isLoading: isLoading) {
                onSubmit(request)
            }
        }
    }
}

struct ApproveOrderWithCardForm: View {
    
    let isLoading: Bool
    let onSubmit: (_ request: DemoApproveOrderWithCardRequest) -> Void

    @State var request = DemoApproveOrderWithCardRequest()

    var body: some View {
        FormGroup {
            StepHeader(text: "Enter Card Information")
            CardFormView(
                cards: DemoCard.allCards,
                cardNumberText: $request.cardNumber,
                expirationDateText: $request.cardExpirationDate,
                cvvText: $request.cardCVV
            )
            SegmentedEnumPicker(label: "SCA", selection: $request.sca)
                .frame(height: 48)
            
            ButtonWithProgress(label: "Approve Order", isLoading: isLoading) {
                onSubmit(request)
            }
        }
    }
}

struct CardResultView: View {
    
    let cardResult: CardResult
    
    var body: some View {
        FormGroup {
            StepHeader(text: "Card Approval Result")
            LeadingText("ID", weight: .bold)
            LeadingText("\(cardResult.orderID)")
            if let status = cardResult.status {
                LeadingText("Order Status", weight: .bold)
                LeadingText("\(status)")
            }
            LeadingText("didAttemptThreeDSecureAuthentication", weight: .bold)
            LeadingText("\(cardResult.didAttemptThreeDSecureAuthentication)")
        }
    }
}
