import SwiftUI

struct ButtonWithProgress: View {
    
    enum State { case idle, loading }
    
    let label: String
    let state: State
    let action: () -> Void
    
    var body: some View {
        let isLabelVisible = state == .idle
        ZStack {
            Button(action: action) {
                Text(label)
            }
            .buttonStyle(RoundedBlueButtonStyle(isLabelVisible: isLabelVisible))
            if state == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
}
