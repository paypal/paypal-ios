import SwiftUI

struct CreateOrderVaultView: View {

    let selectedMerchantIntegration: MerchantIntegration
    @Binding var intent: String

    @ObservedObject var cardVaultViewModel: CardVaultViewModel

    @State private var selectedIntent: Intent = .authorize

    enum Intent: String, CaseIterable, Identifiable {
        case authorize = "AUTHORIZE"
        case capture = "CAPTURE"
        var id: Self { self }
    }

    public init(
        cardVaultViewModel: CardVaultViewModel,
        selectedMerchantIntegration: MerchantIntegration,
        intent: Binding<String>
    ) {
        self.cardVaultViewModel = cardVaultViewModel
        self.selectedMerchantIntegration = selectedMerchantIntegration
        self._intent = intent
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create an Order")
                    .font(.system(size: 20))
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .font(.headline)
            Picker("Intent", selection: $selectedIntent) {
                Text("AUTHORIZE").tag(Intent.authorize)
                Text("CAPTURE").tag(Intent.capture)
            }
            .pickerStyle(SegmentedPickerStyle())
            ZStack {
                Button("Create an Order") {
                    Task {
                        do {
                            intent = selectedIntent.rawValue
                            try await cardVaultViewModel.createOrder(
                                amount: "10.00",
                                selectedMerchantIntegration: selectedMerchantIntegration,
                                intent: intent)
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = cardVaultViewModel.state.createdOrderResponse {
                    CircularProgressView()
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
        .padding(5)
    }
}
