import SwiftUI
import CardPayments

extension SCA: @retroactive CaseIterable {
    
    public static var allCases: [SCA] = [.scaAlways, .scaWhenRequired]
}

struct CardPaymentView: View {
    
    // TODO: there should be a way for us to prevent having to create a new shadow type; we need
    // to remove the requirement to have loading state require Decodable and Equatable conformance
    struct CardResult: Decodable, Equatable {
        
        let id: String
        let status: String?
        let didAttemptThreeDSecureAuthentication: Bool
    }

    @StateObject var cardPaymentViewModel = CardPaymentViewModel()
    @State var createOrderState: LoadingState<Order> = .idle
    @State var approveOrderResult: LoadingState<CardResult> = .idle
    @State var captureAuthorizeResult: LoadingState<Order> = .idle

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CreateOrderForm(onCreateOrderRequest: { request in
                    createOrderState = .loading
                    Task {
                        createOrderState = await cardPaymentViewModel.createOrder(using: request)
                    }
                }, isLoading: createOrderState.isLoading)
                if let order = createOrderState.value {
                    OrderView(order: order)
                    ApproveOrderForm(
                        onApproveOrderRequest: { request in
                            approveOrderResult = .loading
                            Task {
                                approveOrderResult = await cardPaymentViewModel.approveOrder(using: request)
                            }
                        },
                        orderID: order.id,
                        isLoading: approveOrderResult.isLoading
                    )
                    if let cardResult = approveOrderResult.value {
                        CardResultView(cardResult: cardResult)
                        // TODO: grab intent from state somewhere
                        CaptureAuthorizeForm(onCaptureAuthorizeRequest: {
                            captureAuthorizeResult = .loading
                                Task {
                                    captureAuthorizeResult = await cardPaymentViewModel.captureOrder(orderID: order.id)
                                }
                            },
                            intent: .capture,
                            isLoading: captureAuthorizeResult.isLoading
                        )
                        if let captureResult = captureAuthorizeResult.value {
                            OrderView(order: captureResult)
                        }
                    }
                    
//                    NavigationLink {
//                        CardOrderApproveView(orderID: order.id, cardPaymentViewModel: cardPaymentViewModel)
//                    } label: {
//                        Text("Approve Order with Card")
//                    }
//                    .buttonStyle(RoundedBlueButtonStyle())
//                    .padding()
                }
            }
        }
    }
}

struct CreateOrderForm: View {
    
    let onCreateOrderRequest: (DemoCreateOrderRequest) -> Void
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
                let demoOrder = DemoCreateOrderRequest(
                    intent: intent,
                    shouldVault: shouldVault,
                    vaultCustomerID: vaultCustomerID
                )
                onCreateOrderRequest(demoOrder)
            }
        }
    }
}

struct ApproveOrderForm: View {

    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 27"
    @State private var cvvText: String = "123"
    @State private var sca: SCA = .scaAlways

    let cardSections: [CardSection] = [
        CardSection(title: "Successful Authentication Visa", numbers: ["4868 7194 6070 7704"]),
        CardSection(title: "Vault with Purchase (no 3DS)", numbers: ["4000 0000 0000 0002"]),
        CardSection(title: "Step up", numbers: ["5314 6090 4083 0349"]),
        CardSection(title: "Frictionless - LiabilityShift Possible", numbers: ["4005 5192 0000 0004"]),
        CardSection(title: "Frictionless - LiabilityShift NO", numbers: ["4020 0278 5185 3235"]),
        CardSection(title: "No Challenge", numbers: ["4111 1111 1111 1111"])
    ]
    
    let onApproveOrderRequest: (DemoApproveOrderRequest) -> Void
    let orderID: String
    let isLoading: Bool
    
    var body: some View {
        FormGroup {
            StepHeader(text: "Enter Card Information")
            CardFormView(
                cardSections: cardSections,
                cardNumberText: $cardNumberText,
                expirationDateText: $expirationDateText,
                cvvText: $cvvText
            )
            SegmentedEnumPicker(selection: $sca)
                .frame(height: 48)
            ButtonWithProgress(label: "Approve Order", state: isLoading ? .loading : .idle) {
                let card = Card.createCard(
                    cardNumber: cardNumberText,
                    expirationDate: expirationDateText,
                    cvv: cvvText
                )
                let approveOrderRequest =
                    DemoApproveOrderRequest(card: card, orderID: orderID, sca: sca)
                onApproveOrderRequest(approveOrderRequest)
            }
        }
    }
}

struct CardResultView: View {
    
    let cardResult: CardPaymentView.CardResult
    
    var body: some View {
        FormGroup {
            StepHeader(text: "Card Approval Result")
            LeadingText("ID", weight: .bold)
            LeadingText("\(cardResult.id)")
            if let status = cardResult.status {
                LeadingText("Order Status", weight: .bold)
                LeadingText("\(status)")
            }
            LeadingText("didAttemptThreeDSecureAuthentication", weight: .bold)
            LeadingText("\(cardResult.didAttemptThreeDSecureAuthentication)")
        }
    }
}

struct CaptureAuthorizeForm: View {
    
    let onCaptureAuthorizeRequest: () -> Void
    let intent: Intent
    let isLoading: Bool
    
    var body: some View {
        let capitalizedIntent = intent.rawValue.capitalized
        FormGroup {
            StepHeader(text: "\(capitalizedIntent) Order")
            ButtonWithProgress(label: capitalizedIntent, state: isLoading ? .loading : .idle) {
                onCaptureAuthorizeRequest()
            }
        }
    }
}


#Preview {
    CreateOrderForm(onCreateOrderRequest: { _ in }, isLoading: false)
}
