import SwiftUI

struct CardFormOrderCompletionView: View {

    @ObservedObject var cardFormViewModel: BrandedCardFormViewModel

    var body: some View {
        VStack {
            ZStack {
                Button("\(cardFormViewModel.intent.rawValue.capitalized) Order") {
                    Task {
                        do {
                            try await cardFormViewModel.completeTransaction()
                        } catch {
                            print("Error capturing order: \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()

                if cardFormViewModel.state.capturedOrderResponse == .loading ||
                    cardFormViewModel.state.authorizedOrderResponse == .loading {
                    CircularProgressView()
                }
            }
        }
    }
}
