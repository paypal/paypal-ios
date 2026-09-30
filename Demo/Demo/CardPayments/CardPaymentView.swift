import SwiftUI
import CardPayments

struct CardPaymentView: View {
    
    @Environment(CardPaymentViewModel.self)
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
                        ApproveOrderForm(isLoading: isApproveOrderLoading) { request in
                            viewModel.approveOrder(using: request)
                        }
                    }
                    if let cardResult = viewModel.approveOrderState.value {
                        CardResultView(cardResult: cardResult)
                        CompleteOrderForm(
                            intent: viewModel.orderIntent,
                            isLoading: isCompleteOrderLoading
                        ) {
                            viewModel.completeOrder()
                        }
                    }
                    if let captureResult = viewModel.completeOrderState.value {
                        OrderView(order: captureResult)
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

struct ApproveOrderForm: View {
    
    let isLoading: Bool
    let onSubmit: (_ request: DemoApproveOrderRequest) -> Void

    @State var request = DemoApproveOrderRequest()

    let cardSections: [CardSection] = [
        CardSection(title: "Successful Authentication Visa", numbers: ["4868 7194 6070 7704"]),
        CardSection(title: "Vault with Purchase (no 3DS)", numbers: ["4000 0000 0000 0002"]),
        CardSection(title: "Step up", numbers: ["5314 6090 4083 0349"]),
        CardSection(title: "Frictionless - LiabilityShift Possible", numbers: ["4005 5192 0000 0004"]),
        CardSection(title: "Frictionless - LiabilityShift NO", numbers: ["4020 0278 5185 3235"]),
        CardSection(title: "No Challenge", numbers: ["4111 1111 1111 1111"])
    ]
    
    var body: some View {
        FormGroup {
            StepHeader(text: "Enter Card Information")
            CardFormView(
                cardSections: cardSections,
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

struct CompleteOrderForm: View {
    
    let intent: Intent
    let isLoading: Bool
    let onSubmit: () -> Void

    @Environment(CardPaymentViewModel.self)
    var viewModel
    
    var body: some View {
        let capitalizedIntent = intent.rawValue.capitalized
        FormGroup {
            StepHeader(text: "Complete Order")
            let buttonLabel = "\(capitalizedIntent) Order"
            ButtonWithProgress(label: buttonLabel, isLoading: isLoading) {
                onSubmit()
            }
        }
    }
}
