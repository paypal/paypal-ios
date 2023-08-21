import SwiftUI

struct ErrorView: View {

    let errorText: String

    var body: some View {
        VStack {
			Text("\(errorText)")
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 2))
        .padding(5)
        .frame(maxWidth: .infinity)
    }
}
