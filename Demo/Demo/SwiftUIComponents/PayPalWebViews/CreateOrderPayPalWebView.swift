import SwiftUI

struct CreateOrderPayPalWebView: View {

    @ObservedObject var paypalWebViewModel: PayPalWebViewModel

    @State private var selectedIntent: Intent = .authorize

    let selectedMerchantIntegration: MerchantIntegration

    enum Intent: String, CaseIterable, Identifiable {
        case authorize = "AUTHORIZE"
        case capture = "CAPTURE"
        var id: Self { self }
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
                            paypalWebViewModel.state.intent = selectedIntent.rawValue
                            try await paypalWebViewModel.createOrder(
                                amount: "10.00",
                                selectedMerchantIntegration: DemoSettings.merchantIntegration,
                                intent: selectedIntent.rawValue)
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = paypalWebViewModel.state.createdOrderResponse {
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
