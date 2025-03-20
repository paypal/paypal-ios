import SwiftUI
import PaymentButtons
import PayPalBrandedCardForm

struct CardButtonView: View {

    @ObservedObject var cardFormViewModel: BrandedCardFormViewModel

    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 16) {
                HStack {
                    Text("Checkout with Card")
                        .font(.system(size: 20))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .font(.headline)
                ZStack {
                    CardButton.Representable(
                        color: .black,
                        size: .full
                    ) {
                        cardFormViewModel.paymentButtonTapped()
                    }

                    if cardFormViewModel.state.approveResultResponse == .loading &&
                        cardFormViewModel.checkoutResult == nil &&
                        cardFormViewModel.orderID != nil {
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
    }
}
