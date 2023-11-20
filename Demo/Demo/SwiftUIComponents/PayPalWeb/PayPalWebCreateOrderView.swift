import SwiftUI

struct PayPalWebCreateOrderView: View {

    @ObservedObject var payPalWebViewModel: PayPalWebViewModel

    @State private var selectedIntent: Intent = .authorize

    var body: some View {
        VStack {
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
                            payPalWebViewModel.intent = selectedIntent
                            try await payPalWebViewModel.createOrder()
                        } catch {
                            print("Error in getting setup token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if payPalWebViewModel.state == .loading {
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
