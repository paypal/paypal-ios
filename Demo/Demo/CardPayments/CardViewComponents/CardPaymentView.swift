import SwiftUI
import CardPayments

extension SCA: @retroactive CaseIterable {
    
    public static var allCases: [SCA] = [.scaAlways, .scaWhenRequired]
}

struct CardPaymentView: View {
    
    @StateObject var viewModel = CardPaymentViewModelV2()

    // TODO: there should be a way for us to prevent having to create a new shadow type; we need
    // to remove the requirement to have loading state require Decodable and Equatable conformance
    struct CardResult: Decodable, Equatable {
        
        let id: String
        let status: String?
        let didAttemptThreeDSecureAuthentication: Bool
    }

    @StateObject var cardPaymentViewModel = CardPaymentViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CreateOrderForm()
                if let order = viewModel.createOrderState.value {
                    OrderView(order: order)
                    ApproveOrderForm()
                    if let cardResult = viewModel.approveOrderResult.value {
                        CardResultView(cardResult: cardResult)
                        CaptureAuthorizeForm()
                        if let captureResult = viewModel.captureAuthorizeResult.value {
                            OrderView(order: captureResult)
                        }
                    }
                }
            }
        }
        .environmentObject(viewModel)
    }
}

struct CreateOrderForm: View {
    
    @EnvironmentObject var viewModel: CardPaymentViewModelV2
    
    @State var intent: Intent = .capture
    @State var shouldVault = false
    @State private var vaultCustomerID: String = ""

    var body: some View {
        FormGroup {
            StepHeader(text: "Create Order")
            SegmentedEnumPicker(selection: $intent)
            Toggle("Should Vault with Purchase", isOn: $shouldVault)
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $vaultCustomerID)
            
            let isLoading = viewModel.createOrderState.isLoading
            ButtonWithProgress(label: "Create an Order", state: isLoading ? .loading : .idle) {
                let demoOrder = DemoCreateOrderRequest(
                    intent: intent,
                    shouldVault: shouldVault,
                    vaultCustomerID: vaultCustomerID
                )
                viewModel.createOrder(using: demoOrder)
            }
        }
    }
}

struct ApproveOrderForm: View {
    
    @EnvironmentObject var viewModel: CardPaymentViewModelV2

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
            
            let isLoading = viewModel.approveOrderResult.isLoading
            ButtonWithProgress(label: "Approve Order", state: isLoading ? .loading : .idle) {
                let card = Card.createCard(
                    cardNumber: cardNumberText,
                    expirationDate: expirationDateText,
                    cvv: cvvText
                )
                if let order = viewModel.createOrderState.value {
                    let approveOrderRequest =
                    DemoApproveOrderRequest(card: card, orderID: order.id, sca: sca)
                    viewModel.approveOrder(using: approveOrderRequest)
                }
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
    
    @EnvironmentObject var viewModel: CardPaymentViewModelV2

    // TODO: grab intent from state somewhere
    let intent: Intent = .capture

    var body: some View {
        let capitalizedIntent = intent.rawValue.capitalized
        FormGroup {
            StepHeader(text: "Complete Order")
            let isLoading = viewModel.captureAuthorizeResult.isLoading
            ButtonWithProgress(label: "\(capitalizedIntent) Order", state: isLoading ? .loading : .idle) {
                viewModel.completeOrder()
            }
        }
    }
}


//#Preview {
//    CreateOrderForm()
//}
