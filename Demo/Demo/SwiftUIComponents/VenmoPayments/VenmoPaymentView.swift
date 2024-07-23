import SwiftUI
import CorePayments

struct VenmoPaymentView: View {
    
    @State private var selectedIntent: EligibilityIntent = .capture
    @StateObject var venmoPaymentsViewModel = VenmoPaymentsViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, Venmo!")
            Picker("Intent", selection: $selectedIntent) {
                Text("AUTHORIZE").tag(EligibilityIntent.authorize)
                Text("CAPTURE").tag(EligibilityIntent.capture)
            }
            .pickerStyle(SegmentedPickerStyle())
            ZStack {
                Button("Check eligibility") {
                    Task {
                        do {
                            try await venmoPaymentsViewModel.getEligibility(selectedIntent)
                        } catch {
                            print("Error in getting payment token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = venmoPaymentsViewModel.state {
                    CircularProgressView()
                }
            }
            if case .success = venmoPaymentsViewModel.state {
                if venmoPaymentsViewModel.isVenmoEligible {
                    Text("Venmo is eligible! 🥳")
                } else {
                    Text("Venmo is not eligible! 🫤")
                }
            }
            if case .error(let message) = venmoPaymentsViewModel.state {
                Text(message)
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

#Preview {
    VenmoPaymentView()
}
