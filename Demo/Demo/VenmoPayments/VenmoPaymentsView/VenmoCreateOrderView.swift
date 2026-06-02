import SwiftUI

struct VenmoCreateOrderView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    @State private var selectedIntent: Intent = .authorize

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Create an Order")
                    .font(.system(size: 20))
                Spacer()
                Button("Reset") {
                    venmoViewModel.resetState()
                }
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
                            venmoViewModel.intent = selectedIntent
                            try await venmoViewModel.createOrder()
                        } catch {
                            print("Error in creating order. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = venmoViewModel.state.createdOrderResponse {
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
