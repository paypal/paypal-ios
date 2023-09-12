import SwiftUI

struct CircularProgressView: View {

    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
            .background(Color.black.opacity(0.4))
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    
    static var previews: some View {
        CircularProgressView()
    }
}
