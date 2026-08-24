import SwiftUI

struct VenmoButtonsView: View {

    @ObservedObject var venmoViewModel: VenmoViewModel

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 16) {
                HStack {
                    Text("Checkout with Venmo")
                        .font(.system(size: 20))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .font(.headline)
                ZStack {
                    Button("Pay with Venmo") {
                        venmoViewModel.venmoButtonTapped()
                    }
                    .buttonStyle(RoundedBlueButtonStyle())
                    if venmoViewModel.state.approveResultResponse == .loading &&
                        venmoViewModel.checkoutResult == nil &&
                        venmoViewModel.orderID != nil {
                        CircularProgressView()
                    }
                }
            }
            .frame(height: 150)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 2)
                    .padding(5)
            )
        }
        .onOpenURL { url in
            venmoViewModel.handleReturnURL(url)
        }
    }
}
