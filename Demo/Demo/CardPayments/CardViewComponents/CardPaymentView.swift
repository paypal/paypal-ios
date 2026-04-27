import SwiftUI
import CardPayments

extension SCA: @retroactive CaseIterable {
    
    public static var allCases: [SCA] = [.scaAlways, .scaWhenRequired]
}

struct CardPaymentView: View {
    
    @StateObject var viewModel = CardPaymentViewModelV2()
    
    @StateObject var createOrderRequest = DemoCreateOrderRequest()
    @StateObject var approveOrderRequest = DemoApproveOrderRequest()

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
                CreateOrderForm(request: createOrderRequest)
                if let order = viewModel.createOrderState.value {
                    OrderView(order: order)
                    ApproveOrderForm(request: approveOrderRequest)
                    if let cardResult = viewModel.approveOrderResult.value {
                        CardResultView(cardResult: cardResult)
                        CaptureAuthorizeForm(request: createOrderRequest)
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
    
    @ObservedObject var request: DemoCreateOrderRequest
    @EnvironmentObject var viewModel: CardPaymentViewModelV2
    
    var body: some View {
        FormGroup {
            StepHeader(text: "Create Order")
            SegmentedEnumPicker(selection: $request.intent)
            Toggle("Should Vault with Purchase", isOn: $request.shouldVault)
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $request.vaultCustomerID)
            
            let isLoading = viewModel.createOrderState.isLoading
            ButtonWithProgress(label: "Create an Order", state: isLoading ? .loading : .idle) {
                viewModel.createOrder(using: request)
            }
        }
    }
}

struct ApproveOrderForm: View {
    
    @ObservedObject var request: DemoApproveOrderRequest
    @EnvironmentObject var viewModel: CardPaymentViewModelV2

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
            SegmentedEnumPicker(selection: $request.sca)
                .frame(height: 48)
            
            let isLoading = viewModel.approveOrderResult.isLoading
            ButtonWithProgress(label: "Approve Order", state: isLoading ? .loading : .idle) {
                viewModel.approveOrder(using: request)
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
    
    @ObservedObject var request: DemoCreateOrderRequest
    @EnvironmentObject var viewModel: CardPaymentViewModelV2

    var body: some View {
        let intent: Intent = request.intent
        let capitalizedIntent = intent.rawValue.capitalized
        FormGroup {
            StepHeader(text: "Complete Order")
            let isLoading = viewModel.captureAuthorizeResult.isLoading
            ButtonWithProgress(label: "\(capitalizedIntent) Order", state: isLoading ? .loading : .idle) {
                viewModel.completeOrder(intent: intent)
            }
        }
    }
}


//#Preview {
//    CreateOrderForm()
//}
