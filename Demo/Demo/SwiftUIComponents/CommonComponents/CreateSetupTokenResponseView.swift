import SwiftUI
import CardPayments

struct CreateSetupTokenResponseView: View {

    let response: CreateSetupTokenResponse

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Setup Token")
                    .font(.system(size: 20))
                Spacer()
            }
            LeadingText("ID", weight: .bold)
            LeadingText("\(response.id)")
            LeadingText("Customer ID", weight: .bold)
            LeadingText("\(response.customer?.id ?? "")")
            LeadingText("Status", weight: .bold)
            LeadingText("\(response.status)")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
    }
}
