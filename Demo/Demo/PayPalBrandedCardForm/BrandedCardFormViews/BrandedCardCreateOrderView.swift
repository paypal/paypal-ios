import SwiftUI

struct BrandedCardCreateOrderView: View {

    @ObservedObject var cardFormViewModel: BrandedCardFormViewModel

    @State private var selectedIntent: Intent = .authorize
    @State var shouldVaultSelected = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create an Order")
                    .font(.system(size: 20))
                Spacer()
                Button("Reset") {
                    cardFormViewModel.resetState()
                }
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            Picker("Intent", selection: $selectedIntent) {
                Text("AUTHORIZE").tag(Intent.authorize)
                Text("CAPTURE").tag(Intent.capture)
            }
            .pickerStyle(SegmentedPickerStyle())
            HStack {
                Toggle("Should Vault with Purchase", isOn: $shouldVaultSelected)
                Spacer()
            }
            ZStack {
                Button("Create an Order") {
                    Task {
                        do {
                            cardFormViewModel.intent = selectedIntent
                            try await cardFormViewModel.createOrder()
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = cardFormViewModel.state.createdOrderResponse {
                    CircularProgressView()
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
