import SwiftUI
import CardPayments
import CorePayments

struct CardVaultView: View {
    
    @Environment(CardVaultViewModel.self)
    var viewModel
    
    var isCreateSetupTokenLoading: Bool {
        viewModel.createSetupTokenState.isLoading
    }
    
    var isUpdateSetupTokenLoading: Bool {
        viewModel.updateSetupTokenState.isLoading
    }
    
    var isCreatePaymentTokenLoading: Bool {
        viewModel.createPaymentTokenState.isLoading
    }

    // MARK: Views
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateCardSetupTokenForm(isLoading: isCreateSetupTokenLoading) { request in
                        viewModel.createSetupToken(with: request)
                    }
                    if let createSetupTokenResponse = viewModel.createSetupTokenState.value {
                        CreateSetupTokenResponseView(response: createSetupTokenResponse)
                        UpdateSetupTokenForm(isLoading: isUpdateSetupTokenLoading) { card in
                            viewModel.updateSetupToken(with: card)
                        }
                    }
                    if let updateSetupTokenResult = viewModel.updateSetupTokenState.value {
                        UpdateSetupTokenResultView(result: updateSetupTokenResult)
                        CreatePaymentTokenForm(isLoading: isCreatePaymentTokenLoading) {
                            viewModel.createPaymentToken()
                        }
                    }
                    if let paymentTokenResponse = viewModel.createPaymentTokenState.value {
                        PaymentTokenResponseView2(response: paymentTokenResponse)
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

// TODO: move to its own file
// TODO: rename to SetupTokenView
struct CreateSetupTokenResponseView: View {
    
    let response: CreateSetupTokenResponse
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Setup Token")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(response.id)")
            LeadingText("Customer ID", weight: .bold)
            LeadingText("\(response.customer?.id ?? "")")
            LeadingText("Status", weight: .bold)
            LeadingText("\(response.status)")
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

struct UpdateSetupTokenForm: View {
    
    let isLoading: Bool
    let onSubmit: (_ card: Card) -> Void
    
    @State private var cardNumberText: String = "4111 1111 1111 1111"
    @State private var expirationDateText: String = "01 / 27"
    @State private var cvvText: String = "123"

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Card")
                    .font(.system(size: 20))
                Spacer()
            }

            CardFormView(
                cardSections: CardSection.allSections,
                cardNumberText: $cardNumberText,
                expirationDateText: $expirationDateText,
                cvvText: $cvvText
            )

            let card = Card.createCard(
                cardNumber: cardNumberText,
                expirationDate: expirationDateText,
                cvv: cvvText
            )
            ZStack {
                ButtonWithProgress(label: "Update Setup Token", isLoading: isLoading) {
                    onSubmit(card)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}

struct UpdateSetupTokenResultView: View {
    
    let result: UpdateSetupTokenResult

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Success")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(result.id)")
            if let status = result.status {
                LeadingText("status", weight: .bold)
                LeadingText("\(status)")
            }

            LeadingText("didAttemptThreeDSecureAuthentication", weight: .bold)
            LeadingText("\(result.didAttemptThreeDSecureAuthentication)")
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

struct CreatePaymentTokenForm: View {
    
    let isLoading: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create a Payment Method Token")
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            ZStack {
                ButtonWithProgress(label: "Create Payment Token", isLoading: isLoading) {
                    onSubmit()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}

struct CardVault_Previews: PreviewProvider {

    static var previews: some View {
        CardVaultView()
    }
}
