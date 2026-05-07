import SwiftUI

struct RoundedBlueButtonStyle: ButtonStyle {
    
    var isLabelVisible = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isLabelVisible ? .white : .clear)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.blue)
            .cornerRadius(8)
    }
}
