import SwiftUI

struct SetupTokenResultView: View {

    let setupTokenResponse: SetUpTokenResponse

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Setup Token")
                    .font(.system(size: 20))
                Spacer()
            }
            Text("ID")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(setupTokenResponse.id)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Customer ID")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(setupTokenResponse.customer?.id ?? "")")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Status")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(setupTokenResponse.status)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
        .padding(5)
    }
}
