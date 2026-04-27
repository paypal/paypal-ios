import SwiftUI

struct ButtonWithProgress: View {
    
    enum State { case idle, loading }
    
    let label: String
    let state: State
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Group {
                if state == .idle {
                    Text(label)
                } else {
                    CircularProgressView()
                }
            }
        }
    }
}
