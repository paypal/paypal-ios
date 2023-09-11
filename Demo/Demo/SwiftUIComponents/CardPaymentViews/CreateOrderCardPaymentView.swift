import SwiftUI

struct CreateOrderCardPaymentView: View {

    @ObservedObject var cardPaymentViewModel: CardPaymentViewModel

    @State private var selectedIntent: Intent = .authorize
    @State private var vaultCustomerID: String = ""
    @State var shouldVaultSelected = false

    let selectedMerchantIntegration: MerchantIntegration

    enum Intent: String, CaseIterable, Identifiable {
        case authorize = "AUTHORIZE"
        case capture = "CAPTURE"
        var id: Self { self }
    }

    public init(
        cardPaymentViewModel: CardPaymentViewModel,
        selectedMerchantIntegration: MerchantIntegration
    ) {
        self.cardPaymentViewModel = cardPaymentViewModel
        self.selectedMerchantIntegration = selectedMerchantIntegration
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
            HStack {
                Toggle("Should Vault with Purchase", isOn: $shouldVaultSelected)
                // TODO: turn on if vault with purchase on sample server is implemented
                    .disabled(true)
                Spacer()
            }
            FloatingLabelTextField(placeholder: "Vault Customer ID (Optional)", text: $vaultCustomerID)
            ZStack {
                Button("Create an Order") {
                    Task {
                        do {
                            cardPaymentViewModel.state.intent = selectedIntent.rawValue
                            try await cardPaymentViewModel.createOrder(
                                amount: "10.00",
                                selectedMerchantIntegration: DemoSettings.merchantIntegration,
                                intent: selectedIntent.rawValue
                            )
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = cardPaymentViewModel.state.createdOrderResponse {
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
