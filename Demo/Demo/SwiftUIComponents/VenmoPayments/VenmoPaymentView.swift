import SwiftUI

struct VenmoPaymentView: View {
    
    @StateObject var venmoPaymentsViewModel = VenmoPaymentsViewModel()
    
    var body: some View {
        VStack {
            Text("Hello, Venmo!")
            ZStack {
                Button("Check eligibility") {
                    Task {
                        do {
                            try await venmoPaymentsViewModel.getEligibility()
                        } catch {
                            print("Error in getting payment token. \(error.localizedDescription)")
                        }
                    }
                }
                .buttonStyle(RoundedBlueButtonStyle())
                if case .loading = venmoPaymentsViewModel.state.isVenmoEligibleResponse {
                    CircularProgressView()
                }
            }
            if case .loaded(let value) = venmoPaymentsViewModel.state.isVenmoEligibleResponse {
                if value {
                    Text("Venmo is eligible! 🥳")
                } else {
                    Text("Venmo is not eligible! 🫤")
                }
            }
        }
    }
}

#Preview {
    VenmoPaymentView()
}
