import SwiftUI
import CardPayments
import CorePayments

struct CardVaultView: View {
    
    @Environment(CardVaultViewModel.self)
    var viewModel
    
    var isCreateSetupTokenLoading: Bool {
        viewModel.createSetupTokenState.isLoading
    }

    // MARK: Views
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollView in
                VStack(spacing: 16) {
                    CreateCardSetupTokenForm(isLoading: isCreateSetupTokenLoading) { request in
                        viewModel.createSetupToken(with: request)
                    }
                    if let setupTokenResponse = viewModel.createSetupTokenState.value {
                        CreateSetupTokenResponseView(response: setupTokenResponse)
                        UpdateSetupTokenForm(isLoading: false) { card in
                            viewModel.updateSetupToken(with: card)
                        }
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
                ButtonWithProgress(label: "Checkout", isLoading: isLoading) {
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

//struct UpdateSetupTokenResultView: View {
//    
//    let response: UpdateSetupTokenResult
//
//    @ObservedObject var cardVaultViewModel: CardVaultViewModelLegacy
//
//    var body: some View {
//        switch cardVaultViewModel.state.updateSetupTokenResponse {
//        case .idle, .loading:
//            EmptyView()
//        case .loaded(let updateSetupTokenResponse):
//            getSuccessView(updateSetupTokenResponse: updateSetupTokenResponse)
//        case .error(let errorMessage):
//            ErrorView(errorMessage: errorMessage)
//        }
//    }
//
//    func getSuccessView(updateSetupTokenResponse: UpdateSetupTokenResult) -> some View {
//        VStack(spacing: 16) {
//            HStack {
//                Text("Vault Success")
//                    .font(.system(size: 20))
//                Spacer()
//            }
//            LeadingText("ID", weight: .bold)
//            LeadingText("\(updateSetupTokenResponse.id)")
//            if let status = updateSetupTokenResponse.status {
//                LeadingText("status", weight: .bold)
//                LeadingText("\(status)")
//            }
//
//            LeadingText("didAttemptThreeDSecureAuthentication", weight: .bold)
//            LeadingText("\(updateSetupTokenResponse.didAttemptThreeDSecureAuthentication)")
//        }
//        .frame(maxWidth: .infinity)
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(.gray, lineWidth: 2)
//                .padding(5)
//        )
//    }
//}

struct CardVault_Previews: PreviewProvider {

    static var previews: some View {
        CardVaultView()
    }
}
