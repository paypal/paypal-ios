import SwiftUI
import CardPayments

struct CardPaymentView: View {
    
    @SwiftUI.Environment(CardPaymentViewModel.self)
    var viewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateOrderForm()
                    if let order = viewModel.createOrderState.value {
                        OrderView(order: order)
                        ApproveOrderForm()
                    }
                    if let cardResult = viewModel.approveOrderState.value {
                        CardResultView(cardResult: cardResult)
                        CompleteOrder()
                    }
                    if let captureResult = viewModel.completeOrderState.value {
                        OrderView(order: captureResult)
                    }
                    ScrollAnchor(id: "bottomAnchor")
                }
                .onChange(of: viewModel.stepCount) { _, _ in
                    withAnimation {
                        proxy.scrollTo("bottomAnchor")
                    }
                }
            }
        }
    }
}

struct CreateOrderForm: View {
    
    @SwiftUI.Environment(CardPaymentViewModel.self)
    var viewModel
    
    var body: some View {
        @Bindable var request = viewModel.createOrderRequest
        FormGroup {
            StepHeader(text: "Create Order")
            SegmentedEnumPicker(label: "Intent", selection: $request.intent)
            Toggle("Should Vault with Purchase", isOn: $request.shouldVault)
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $request.vaultCustomerID)
            
            let isLoading = viewModel.createOrderState.isLoading
            ButtonWithProgress(label: "Create an Order", isLoading: isLoading) {
                viewModel.createOrder(using: request)
            }
        }
    }
}

struct ApproveOrderForm: View {
    
    @SwiftUI.Environment(CardPaymentViewModel.self)
    var viewModel
    
    let cardSections: [CardSection] = [
        CardSection(title: "Successful Authentication Visa", numbers: ["4868 7194 6070 7704"]),
        CardSection(title: "Vault with Purchase (no 3DS)", numbers: ["4000 0000 0000 0002"]),
        CardSection(title: "Step up", numbers: ["5314 6090 4083 0349"]),
        CardSection(title: "Frictionless - LiabilityShift Possible", numbers: ["4005 5192 0000 0004"]),
        CardSection(title: "Frictionless - LiabilityShift NO", numbers: ["4020 0278 5185 3235"]),
        CardSection(title: "No Challenge", numbers: ["4111 1111 1111 1111"])
    ]
    
    var body: some View {
        @Bindable var request: DemoApproveOrderRequest = viewModel.approveOrderRequest
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
            
            let isLoading = viewModel.approveOrderState.isLoading
            ButtonWithProgress(label: "Approve Order", isLoading: isLoading) {
                viewModel.approveOrder(using: request)
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

struct CompleteOrder: View {
    
    @SwiftUI.Environment(CardPaymentViewModel.self)
    var viewModel
    
    var body: some View {
        let request = viewModel.createOrderRequest
        let intent = request.intent
        let capitalizedIntent = request.intent.rawValue.capitalized
        FormGroup {
            StepHeader(text: "Complete Order")
            let buttonLabel = "\(capitalizedIntent) Order"
            let isLoading = viewModel.completeOrderState.isLoading
            ButtonWithProgress(label: buttonLabel, isLoading: isLoading) {
                viewModel.completeOrder(intent: intent)
            }
        }
    }
}
