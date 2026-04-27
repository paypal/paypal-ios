import SwiftUI

struct FormGroup<Content: View>: ContainerView {
    
    var content: () -> Content

    var body: some View {
        VStack(spacing: 16, content: content)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray, lineWidth: 2)
                    .padding(8)
            )
    }
}
