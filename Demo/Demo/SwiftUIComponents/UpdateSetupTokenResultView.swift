import SwiftUI

struct UpdateSetupTokenResultView: View {

    let updateSetupTokenResponse: CardVaultState.UpdateSetupTokenResult

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Vault Success")
                    .font(.system(size: 20))
                Spacer()
            }
            Text("ID")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(updateSetupTokenResponse.id)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Status")
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(updateSetupTokenResponse.status)")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
        .padding(5)
    }
}
