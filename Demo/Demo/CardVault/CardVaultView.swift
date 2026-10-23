import SwiftUI
import CardPayments
import CorePayments

struct CardVaultView: View {
    
    @Environment(CardVaultViewModel.self)
    var viewModel
    
    var createSetupTokenState: AsyncState<CreateSetupTokenResponse> { viewModel.createSetupTokenState }
    var updateSetupTokenState: AsyncState<CardVaultResult> { viewModel.updateSetupTokenState }
    var createPaymentTokenState: AsyncState<PaymentTokenResponse> { viewModel.createPaymentTokenState }

    // MARK: Views
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    CreateCardSetupTokenForm(isLoading: createSetupTokenState.isLoading) { request in
                        viewModel.createSetupToken(with: request)
                    }
                    UnwrapValueOrError(createSetupTokenState) { createSetupTokenResponse in
                        CreateSetupTokenResponseView(response: createSetupTokenResponse)
                        UpdateCardSetupTokenForm(isLoading: updateSetupTokenState.isLoading) { card in
                            viewModel.updateSetupToken(with: card)
                        }
                    }
                    UnwrapValueOrError(updateSetupTokenState) { updateSetupTokenResult in
                        UpdateSetupTokenResultView(result: updateSetupTokenResult)
                        CreatePaymentTokenForm(isLoading: createPaymentTokenState.isLoading) {
                            viewModel.createPaymentToken()
                        }
                    }
                    UnwrapValueOrError(createPaymentTokenState) { paymentTokenResponse in
                        PaymentTokenResponseView(response: paymentTokenResponse)
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

struct UpdateCardSetupTokenForm: View {
    
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
                cards: DemoCard.allCards,
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
    
    let result: CardVaultResult

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Success")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(result.setupTokenID)")
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
            .environment(CardVaultViewModel())
    }
}
