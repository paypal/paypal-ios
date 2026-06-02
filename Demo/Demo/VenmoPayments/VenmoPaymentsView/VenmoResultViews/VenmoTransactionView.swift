import SwiftUI

struct VenmoTransactionView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    var body: some View {
        VStack {
            ZStack {
                Button("\(venmoViewModel.intent.rawValue.capitalized) Order") {
                    Task {
                        do {
                            try await venmoViewModel.completeTransaction()
                        } catch {
                            print("Error completing order: \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                .padding()

                if venmoViewModel.state.capturedOrderResponse == .loading ||
                    venmoViewModel.state.authorizedOrderResponse == .loading {
                    CircularProgressView()
                }
            }
        }
    }
}
