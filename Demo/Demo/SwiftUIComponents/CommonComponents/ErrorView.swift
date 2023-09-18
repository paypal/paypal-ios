import SwiftUI

struct ErrorView: View {

    let errorMessage: String

    var body: some View {
        VStack {
            Text("\(errorMessage)")
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray, lineWidth: 2)
                .padding(5)
        )
        .frame(maxWidth: .infinity)
    }
}
