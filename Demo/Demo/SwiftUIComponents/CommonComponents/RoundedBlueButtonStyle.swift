import SwiftUI

struct RoundedBlueButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue)
            .cornerRadius(10)
    }
}
