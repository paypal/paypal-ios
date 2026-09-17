import SwiftUI

struct ButtonWithProgress: View {
    
    let label: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Button(action: action) {
                Text(label)
            }
            .buttonStyle(RoundedBlueButtonStyle(isLabelVisible: !isLoading))
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
}
